# Lab 10 – Teachable Machine Image Classifier

**Student:** Elshodbek Xushvaqtov (240444)

## Class list (T1)

| # | Class | Notes |
|---|-------|-------|
| 0 | deodorant | black spray can |
| 1 | wallet | black leather wallet |
| 2 | cap | black baseball cap |
| 3 | watch | smartwatch with black strap |
| 4 | charger | phone charger with cable |
| 5 | nothing | background class: empty background, no object |

Samples per class: 74–82, recorded with the laptop webcam. Every class reached 100 % in the Teachable Machine preview on a fresh example (`docs/preview.png`).

**Exported model:** `model_unquant.tflite` (floating point, 2.0 MB), input `float32 [1, 224, 224, 3]`, output `float32 [1, 6]`.

**Smoke test (T10)** on `assets/model/sample.jpg` (phone photo of the deodorant): deodorant 99.7 %, cap 0.3 %, all others 0.0 %, sum = 1.000.

## Design credit (T14)

- **Name:** ______
- **Author:** ______
- **Link:** ______
- **Licence:** ______

## Classifier sharing (T11)

The classifier is loaded once in `main.dart` (`_TmAppState._loadModel`) and passed down with **constructor injection**: `TmApp → MainShell → ModelScreen`. No screen calls `Classifier.load()`. It is closed in `_TmAppState.dispose()`.

---

## Part 1 questions

**What does the model answer for an object that belongs to none of the classes? How does the background class change that?**
The model has no "unknown" answer. Softmax always splits 100 % between the classes it knows, so it picks whichever class looks most similar, often with a high percentage. The background class ("nothing") gives it a place to put images that show no trained object, so the empty background or an unclear picture usually goes there instead of being forced into "wallet" or "cap". It does not fully solve the problem: a completely new object (for example a black phone) can still be called a wallet with high confidence, because it looks more like a wallet than like an empty background.

**Floating point vs Quantized: size, input type, what Dart must do.**
- Floating point: weights stored as 32-bit floats, file is about 4× bigger (around 2 MB). Input is `float32` in the range −1…1, so Dart must normalise every pixel with `value / 127.5 − 1`. Output is float probabilities 0…1.
- Quantized: weights stored as 8-bit integers, file is about 4× smaller and usually faster, with slightly lower accuracy. Input is `uint8` 0…255, so Dart passes raw pixel values with no normalisation. Output is `uint8` 0…255, so Dart divides by 255 to get a probability.

## Part 2 questions

**`assets/model/` vs `assets/`?**
`assets/model/` bundles only the files directly inside `assets/model` (the model, labels and sample.jpg). `assets/` bundles only the files directly inside `assets/` and **not** subfolders, so the model would not be included at all. Flutter does not include subdirectories automatically; each folder must be listed.

**Why can `image` and `http` run in a plain Dart unit test, but `tflite_flutter` and `image_picker` cannot?**
`image` and `http` are pure Dart code. `tflite_flutter` needs the native TensorFlow Lite library (C++ code compiled for Android/iOS) and `image_picker` calls the phone's native camera/gallery through platform channels. A unit test runs on the laptop's Dart VM with no phone and no native plugin, so those calls have nothing to talk to.

## Part 3 questions

**Normalisation changed to `value / 255`: what happens and why no crash?**
The inputs are now 0…1 instead of −1…1. The tensor still has the correct shape and type (float32 [1,224,224,3]), so TensorFlow Lite runs without any error. But the numbers are not what the network saw in training (everything looks bright/washed-out to it), so the percentages become wrong: usually one class wins with high confidence no matter what the picture shows. Shape errors crash, value range errors silently give garbage.

**Where is the number of classes written down? What to edit for a seventh class?**
Nowhere in the code. It comes from the number of lines in `labels.txt` (`labels.length`), and the output list is created with that length. After retraining with seven classes I only replace `model_unquant.tflite` and `labels.txt` in `assets/model/`. No Dart change is needed.

## Part 4 questions

**Two things changed or left out from the Figma design, and why.**
1. ______ (example: replaced the custom illustration on the welcome screen with a Material icon, because the image asset licence was unclear / to keep the app size small).
2. ______ (example: used Material 3 `NavigationBar` instead of the custom tab bar from the design, because it gives pressed states and accessibility for free).

**Does the Model screen read labels from the classifier or from the file again?**
From the classifier (`classifier.labels`). The labels were already read once when the model loaded, so reading the file again is wasted work. More importantly, the classifier's list is the exact list that is paired with the model output, so the Model screen always shows the labels the app is really using. Reading the file again could show something different if the file failed or changed.

## Part 5 questions

**Same object, different score from camera vs downloaded picture: two reasons from the training data.**
1. All training samples came from the laptop webcam: same lighting, same light-grey patterned background, object always held in my hand, same low webcam quality. A downloaded photo has a different background, lighting and camera, so it looks unlike anything the model was trained on.
2. Downloaded images are often a different instance of the object (a different cap or watch, a studio product photo on white, at a different angle/distance). The model learned *my* specific objects, not the general concept.

**`classify` runs on the UI thread. How long does it take, and what does the user see?**
Measured with `Stopwatch` (printed in the console as `classify took … ms`): about ___ ms on our phone. During that time the UI thread is blocked, so the "Classifying…" dialog is shown but its spinner freezes and the app does not react to taps until the result opens.

---

## Checkpoint questions

**1. Trace one photo from the shutter to the percentage on screen.**
1. User taps *Take a photo* → `MainShell._takePhoto` (`lib/screens/main_shell.dart`).
2. `ImageSources.fromCamera` (`lib/services/image_sources.dart`) opens the system camera; `image_picker` resizes the photo to max 1024 px wide and saves a JPEG; `readAsBytes` gives `Uint8List` bytes.
3. `MainShell.handleImage` sends the bytes to `Classifier.classify` (`lib/services/classifier.dart`):
   - `img.decodeImage`: JPEG bytes → pixel image
   - `bakeOrientation`: applies EXIF rotation
   - `copyResizeCropSquare`: centre crop + resize to 224 × 224
   - pixel loop: each 0–255 channel → float −1…1, shape [1,224,224,3]
   - `_interpreter.run`: the network gives output [1, classes] of softmax probabilities
   - pair with labels, sort highest first → `List<Prediction>`
4. `handleImage` wraps it in a `HistoryEntry` (`lib/services/history_entry.dart`), adds it to history and pushes `ResultScreen`.
5. `PredictionRow` (`lib/widgets/prediction_row.dart`) turns confidence into `(confidence * 100).toStringAsFixed(1) %` and a bar.

**2. Three lines of pubspec.yaml that would break the app if deleted.**
1. `- assets/model/`: model not bundled; at start-up `Interpreter.fromAsset` fails ("Unable to load asset: assets/model/model_unquant.tflite") and the welcome screen shows the error.
2. `tflite_flutter: ^0.12.1`: compile error, `Target of URI doesn't exist: 'package:tflite_flutter/tflite_flutter.dart'` and `Interpreter` undefined.
3. `image_picker: ^1.2.3`: compile error, `package:image_picker/image_picker.dart` not found, `ImagePicker` undefined. (Same for `image` / `http`, or `assets:` itself.)

**3. Why must Flutter pre-processing match Teachable Machine's training? Two things that must match.**
The network only learned to recognise inputs that look like its training inputs. If the numbers are different, the weights do not mean anything and the output is confident nonsense. The two things:
1. **Image geometry**: centre square crop resized to 224 × 224 (and correct orientation).
2. **Value range / normalisation**: each channel scaled to −1…1 with `value / 127.5 − 1` (float model), in RGB order.

**4. 97 % sure a shoe is a mug: bug?**
No, it is not a bug in the code. The percentage means "among my six classes, mug is the most similar to this picture, and the softmax gives it 97 % of the total". It is *not* the real probability that the object is a mug, and it does not say how confident the model is that the object belongs to any class. The model has never seen a shoe and has no "unknown" option, so it must pick one of its classes. Fixes: more varied training data, a better background/"other" class, or a confidence threshold.

**5. What stays on the device, what leaves it? Compare with a cloud vision API.**
In this app the model, the photos, the classification and the history all stay on the phone. Inference runs locally, with no server. The only network traffic is the *Download an image* feature, where the phone requests a picture from a URL the user typed (data comes in; our photo does not go out). With a cloud vision API every photo would be uploaded to someone else's server: it needs internet, adds delay, may cost money per request and raises privacy concerns (photos may be stored or logged). In return, the cloud model is much bigger and recognises thousands of objects, not just our six.

---

## Evaluation table (T23)

Three new pictures per class, all three sources used across the test.

| # | Source | Expected | Predicted | % | Correct |
|---|--------|----------|-----------|---|---------|
| 1 | Camera | deodorant | | | |
| 2 | Gallery | deodorant | | | |
| 3 | Download | deodorant | | | |
| 4 | Camera | wallet | | | |
| 5 | Gallery | wallet | | | |
| 6 | Download | wallet | | | |
| 7 | Camera | cap | | | |
| 8 | Gallery | cap | | | |
| 9 | Download | cap | | | |
| 10 | Camera | watch | | | |
| 11 | Gallery | watch | | | |
| 12 | Download | watch | | | |
| 13 | Camera | charger | | | |
| 14 | Gallery | charger | | | |
| 15 | Download | charger | | | |
| 16 | Camera | nothing | | | |
| 17 | Gallery | nothing | | | |
| 18 | Download | nothing | | | |

**Overall accuracy:** __ / 18 = __ %
**Weakest class:** ______
