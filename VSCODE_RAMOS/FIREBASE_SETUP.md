# Firebase Configuration Guide for PlatePrep

This guide explains how to connect your Firebase project with PlatePrep to enable live **Firebase Authentication** and **Cloud Firestore**.

---

## 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it **PlatePrep** (e.g. `plateprep-app`).
3. Enable or disable Google Analytics as desired, then click **Create Project**.

---

## 2. Enable Firebase Authentication

1. In the Firebase Console, go to **Build > Authentication**.
2. Click **Get Started**.
3. Under **Sign-in method**, choose **Email/Password**.
4. Enable **Email/Password** (leave Email link disabled) and click **Save**.

---

## 3. Enable Cloud Firestore

1. In the Firebase Console, go to **Build > Firestore Database**.
2. Click **Create database**.
3. Choose your closest database location (e.g., `asia-east1`, `us-central1`, `europe-west1`).
4. Start in **Production mode** or **Test mode**.
5. Once created, paste the following **Security Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User profiles collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Meals collection: Scoped to user's own items
    match /meals/{mealId} {
      allow read, update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }

    // Grocery items collection: Scoped to user's own items
    match /groceryItems/{itemId} {
      allow read, update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 4. Connect PlatePrep using FlutterFire CLI (Recommended)

1. Ensure the Firebase CLI is installed:
   ```bash
   npm install -g firebase-tools
   # or
   curl -sL https://firebase.tools | bash
   ```
2. Log into Firebase:
   ```bash
   firebase login
   ```
3. Activate the FlutterFire CLI globally:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Run configuration in your project root:
   ```bash
   flutterfire configure
   ```
5. Select your Firebase project (`plateprep-app`) and platforms (Android, iOS, Web).
6. This automatically updates `lib/firebase_options.dart` and downloads `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

---

## 5. Manual Configuration (Alternative)

### Android
1. Add an Android app in the Firebase Console with Package Name: `com.example.plateprep`.
2. Download `google-services.json` and place it in:
   `android/app/google-services.json`.

### iOS
1. Add an iOS app in the Firebase Console with Bundle ID: `com.example.plateprep`.
2. Download `GoogleService-Info.plist` and place it in:
   `ios/Runner/GoogleService-Info.plist`.

### Web
1. Add a Web app in the Firebase Console.
2. Copy the config parameters (`apiKey`, `appId`, `messagingSenderId`, `projectId`) into the `web` object in `lib/firebase_options.dart`.

