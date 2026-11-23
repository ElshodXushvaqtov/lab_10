# Lab 10 – Teachable Machine Image Classifier

**Student:** Elshodbek Xushvaqtov (240444)

## Classes (T1)

| # | Class | What it is |
|---|-------|------------|
| 0 | deodorant | black spray can |
| 1 | wallet | black leather wallet |
| 2 | cap | black baseball cap |
| 3 | watch | smartwatch, black strap |
| 4 | charger | phone charger with cable |
| 5 | nothing | empty background, no object |

I recorded about 74–82 samples per class with my laptop webcam. In the Teachable Machine preview every class got 100 % on a new example (screenshot: `docs/preview.png`).

**Model:** `model_unquant.tflite` (floating point, 2.0 MB). Input is `float32 [1, 224, 224, 3]`, output is `float32 [1, 6]`.

**Smoke test (T10):** I used `assets/model/sample.jpg` (phone photo of the deodorant). Result: deodorant 99.7 %, cap 0.3 %, the rest 0.0 %. Total = 1.000.

## Design credit (T14)

- **Name:** TimePad Time Tracker UI Kit
- **Author:** Rizki Mulyawan
- **Link:** https://www.figma.com/community/file/877861267642234232/timepad-time-tracker-ui-kit
- **Licence:** CC BY 4.0

## Sharing the classifier (T11)

The classifier is loaded only once in `main.dart` (`_TmAppState._loadModel`). Then I pass it through the constructors: `TmApp → MainShell → ModelScreen`. No screen calls `Classifier.load()` by itself. It gets closed in `_TmAppState.dispose()`.

---

## Part 1

**What does the model say for an object that is not in any class? What does the background class change?**
The model can't say "I don't know". Softmax always splits 100 % between the classes it has, so it just picks the most similar one, often with a high %. The "nothing" class gives it somewhere to put pictures with no object, so an empty background goes there instead of to "wallet" or "cap". But it doesn't fix everything. A new object like a black phone can still come out as "wallet", because it looks more like a wallet than an empty background.

**Floating point vs Quantized**
- Floating point: weights are 32-bit floats, so the file is about 4× bigger (about 2 MB here). Input is `float32` from −1 to 1, so in Dart I have to do `value / 127.5 − 1` for every pixel. Output is probabilities from 0 to 1.
- Quantized: weights are 8-bit integers, so the file is about 4× smaller and a bit faster, but slightly less accurate. Input is `uint8` 0–255, so I just pass the raw pixels. Output is also 0–255, so I divide by 255.

## Part 2

**`assets/model/` vs `assets/`?**
`assets/model/` includes the files inside that folder (model, labels, sample.jpg). `assets/` only includes files directly in `assets/`, not subfolders, so the model would be missing. Flutter doesn't add subfolders by itself, you have to list each one.

**Why do `image` and `http` work in a normal unit test, but `tflite_flutter` and `image_picker` don't?**
`image` and `http` are just Dart code. `tflite_flutter` needs the native TensorFlow Lite library, and `image_picker` uses the phone's camera/gallery through platform channels. A unit test runs on my laptop's Dart VM, with no phone and no native code, so those plugins can't work there.

## Part 3

**If I change normalisation to `value / 255`, what happens? Why no crash?**
The values become 0–1 instead of −1–1. The shape and type are still right (float32 [1,224,224,3]), so TFLite runs without errors. But the numbers are different from what the model saw in training, so the results are wrong. Usually one class wins with a high % whatever the picture is. So: wrong shape = crash, wrong values = no crash, just bad results.

**Where is the number of classes set? What do I change for a 7th class?**
It's not written anywhere in the code. It comes from how many lines are in `labels.txt` (`labels.length`), and the output list uses that length. For a 7th class I just retrain and replace `model_unquant.tflite` and `labels.txt` in `assets/model/`. No Dart changes needed.

## Part 4

**Two things I changed or left out from the Figma design, and why**
1. On the Welcome screen I used a Material icon instead of the illustration from the design, so the app stays small and I don't need extra image files.
2. I used Flutter's Material 3 `NavigationBar` instead of the custom tab bar from the design, because it already has pressed states and accessibility built in.

**Does the Model screen get the labels from the classifier or read the file again?**
From the classifier (`classifier.labels`). They were already loaded with the model, so reading the file again is pointless. Also this way the screen shows exactly the labels the app is really using for the output. Reading the file again could show something different if it failed or changed.

## Part 5

**Same object, different score from camera vs downloaded picture. Two reasons (training data)**
1. All my training photos came from the laptop webcam: same light, same light-grey background, object always in my hand, same low quality. A downloaded photo is different in all of these.
2. Downloaded pictures usually show a different object (another cap or watch, a product photo on white, a different angle). The model learned my objects, not caps or watches in general.

**`classify` runs on the UI thread. How long does it take and what does the user see?**
I measured it with `Stopwatch` (it prints `classify took … ms` in the console): about 180 ms on my phone. During this time the UI is blocked. The "Classifying…" dialog shows up, but the spinner freezes and taps don't work until the result screen opens.

---

## Checkpoint questions

**1. Follow one photo from taking it to the % on screen.**
1. Tap *Take a photo* → `MainShell._takePhoto` (`lib/screens/main_shell.dart`).
2. `ImageSources.fromCamera` (`lib/services/image_sources.dart`) opens the camera. `image_picker` resizes to max 1024 px and saves a JPEG, then `readAsBytes` gives the bytes.
3. `MainShell.handleImage` sends the bytes to `Classifier.classify` (`lib/services/classifier.dart`):
   - `img.decodeImage`: JPEG → image
   - `bakeOrientation`: fixes the rotation
   - `copyResizeCropSquare`: centre crop to 224 × 224
   - loop over pixels: 0–255 → −1…1, shape [1,224,224,3]
   - `_interpreter.run`: gives [1, classes] probabilities
   - match with labels and sort highest first → `List<Prediction>`
4. `handleImage` makes a `HistoryEntry` (`lib/services/history_entry.dart`), adds it to history and opens `ResultScreen`.
5. `PredictionRow` (`lib/widgets/prediction_row.dart`) shows `(confidence * 100).toStringAsFixed(1) %` and a bar.

**2. Three lines in pubspec.yaml that would break the app if deleted.**
1. `- assets/model/`: the model is not included, so `Interpreter.fromAsset` fails on start ("Unable to load asset: assets/model/model_unquant.tflite") and the welcome screen shows the error.
2. `tflite_flutter: ^0.12.1`: compile error, the import is not found and `Interpreter` is undefined.
3. `image_picker: ^1.2.3`: compile error, `ImagePicker` is undefined. (Same for `image` / `http`, or `assets:` itself.)

**3. Why must the Flutter pre-processing match Teachable Machine? Two things that must match.**
The model only knows inputs that look like its training data. If the numbers are different, the output is confident nonsense.
1. **Image size/crop:** centre square, 224 × 224, correct rotation.
2. **Value range:** every pixel scaled to −1…1 with `value / 127.5 − 1`, in RGB order.

**4. The model is 97 % sure a shoe is a mug. Is it a bug?**
No, the code is fine. 97 % just means "out of my classes, mug is the closest". It's not the real chance that it's a mug. The model never saw a shoe and has no "unknown" option, so it has to pick something. To improve it: more varied training data, a better "other" class, or a minimum confidence threshold.

**5. What stays on the phone and what leaves it? Compare with a cloud API.**
Everything stays on the phone: model, photos, results and history. The model runs locally, no server. The only internet use is *Download an image*, where the app downloads a picture from a URL (nothing gets uploaded). With a cloud API every photo would be sent to someone's server: needs internet, slower, can cost money, and is worse for privacy (photos might be saved). But a cloud model knows thousands of objects, not just six.

---

## Evaluation (T23)

Three new pictures per class, one from each source (18 tests).

| # | Source | Expected | Predicted | % | Correct |
|---|--------|----------|-----------|---|---------|
| 1 | Camera | deodorant | deodorant | 94 | ✓ |
| 2 | Gallery | deodorant | deodorant | 99.4 | ✓ |
| 3 | Download | deodorant | deodorant | 99 | ✓ |
| 4 | Camera | wallet | wallet | 97.2 | ✓ |
| 5 | Gallery | wallet | wallet | 98 | ✓ |
| 6 | Download | wallet | wallet | 87 | ✓ |
| 7 | Camera | cap | cap | 90 | ✓ |
| 8 | Gallery | cap | cap | 99 | ✓ |
| 9 | Download | cap | cap | 99.4 | ✓ |
| 10 | Camera | watch | cap | 84.9 | ✗ |
| 11 | Gallery | watch | watch | 99 | ✓ |
| 12 | Download | watch | watch | 69 | ✓ |
| 13 | Camera | charger | cap | 99.6 | ✗ |
| 14 | Gallery | charger | charger | 99 | ✓ |
| 15 | Download | charger | charger | 86 | ✓ |
| 16 | Camera | nothing | charger | 34.8 | ✗ |
| 17 | Gallery | nothing | nothing | 90 | ✓ |
| 18 | Download | nothing | nothing | 50 | ✓ |

**Accuracy:** 15 / 18 = 83 %

**Weakest class:** nothing. It got 2 / 3, and its scores were the lowest overall (34.8 % wrong, 50 % on the download). Watch and charger also got 2 / 3.

All 3 mistakes came from camera photos on new backgrounds. I took the watch and charger photos lying flat on a bedspread, and "nothing" was a different wallpaper. None of these backgrounds were in my training data, where I always held the object in my hand in front of the same light-grey background. So the model learned that background too, and on a new one it just guesses. The dark watch and charger both came out as "cap".

The downloaded pictures were mostly right, but with lower % (wallet 87, watch 69, charger 86, nothing 50), because they show different objects in different light. To fix this I would add training photos on different backgrounds and with the objects lying on surfaces, not only in my hand.
