# How to put this together

## 1. Create the project and copy the files

```bash
flutter create tm_classifier --empty
cd tm_classifier
flutter pub add tflite_flutter image_picker image http
```

Copy these from this folder into your project (overwrite):
`lib/` (whole folder), `test/labels_test.dart`, `pubspec.yaml`, `NOTES.md`.

Make the folder `assets/model/` next to `lib/` and put in:
- `model_unquant.tflite` and `labels.txt` (from Teachable Machine's zip)
- `sample.jpg`: one photo of a trained object (for the T10 smoke test)

Make `docs/` and add `preview.png`, `design-1.png`, `design-2.png`.

```bash
flutter pub get
flutter analyze
flutter test
```

## 2. Android: `android/app/src/main/AndroidManifest.xml`

Add above the `<application` tag:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

If Gradle complains about `minSdkVersion`, open `android/app/build.gradle.kts` and set:

```kotlin
minSdk = 26   // use the number the error message asks for
```

## 3. iOS: `ios/Runner/Info.plist`

Add inside the main `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>The camera is used to take a photo of the object you want to recognise.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>The gallery is used to pick a picture you want to recognise.</string>
```

## 4. Commit tags

```bash
git add . && git commit -m "Part 1: model" && git tag p1-model
git add . && git commit -m "Part 2: setup" && git tag p2-setup
git add . && git commit -m "Part 3: classifier" && git tag p3-classifier
git add . && git commit -m "Part 4: screens" && git tag p4-screens
git add . && git commit -m "Part 5: sources" && git tag p5-sources
git push && git push --tags
```

## 5. Testing the failure cases (T12)

- **Bad image:** rename a `.txt` file to `.jpg`, put it in the gallery, pick it → a snackbar says "This file is not a readable image."
- **Wrong model path:** change `modelPath` in `classifier.dart` to `model_unqant.tflite` → the welcome screen shows the expected paths in red.
- **Download errors:** try `abc`, `https://google.com` (web page, not image), airplane mode, and a very slow link.

Image URL that works for testing:
`https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/A_small_cup_of_coffee.JPG/640px-A_small_cup_of_coffee.JPG`
