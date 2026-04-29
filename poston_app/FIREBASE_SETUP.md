# Firebase Push Notifications Setup Guide

Here are the exact step-by-step headings and the files you need to get from Firebase to integrate push notifications into your Flutter app.

### 1. Create a Firebase Project
Go to the Firebase Console and create a new project. You don't need to enable Google Analytics unless you want to.

### 2. Register Your Android App
Click the Android icon in your Firebase project. You will need to provide your Android package name (which is `com.example.poston_app` or whatever is in your `android/app/build.gradle`).

### 3. Download the `google-services.json` File
This is the **most important file** for Android. Once you register the Android app, Firebase will give you a `google-services.json` file.
* **Where to put it:** Place this file exactly in the `android/app/` folder of your Flutter project.

### 4. Register Your iOS App (Optional but Recommended)
Click "Add App" and select iOS. You will need your iOS Bundle ID.

### 5. Download the `GoogleService-Info.plist` File
This is the **most important file** for iOS. 
* **Where to put it:** Open the `ios/Runner.xcworkspace` in Xcode, and drag the `GoogleService-Info.plist` file directly into the `Runner` folder inside Xcode.

### 6. Install the Flutter Firebase Packages
Once you have those two files, you will need to let me know so I can run these commands to install the required packages:
* `firebase_core`
* `firebase_messaging`

### 7. Update Android Build Files
We will need to add the Google Services classpath to your `android/build.gradle` and apply the Google Services plugin in your `android/app/build.gradle`. (I can write this code for you when you are ready).

### 8. Initialize Firebase in Flutter
We will update your `main.dart` to run `await Firebase.initializeApp();` before the app starts.

### 9. Request Notification Permissions
We will add logic to ask the user for permission to send them notifications (required for iOS and Android 13+).

### 10. Handle Background and Foreground Messages
We will write the Dart code to listen for notifications when the app is open, closed, or running in the background.

---

**Next Steps for You:**
Go to [console.firebase.google.com](https://console.firebase.google.com/), complete Steps 1 through 5, and drop the `google-services.json` file into your `android/app/` folder. Once you've done that, tell me to continue!

---

# Google Sign-In Setup Guide (for Supabase)

To make the Google Sign-In button work perfectly in your app, you need to link your Google Cloud project with your Supabase project. Here are the exact steps to get the "Client ID" and "Client Secret" shown in your Supabase dashboard.

### 1. Go to Google Cloud Console
Go to the [Google Cloud Console](https://console.cloud.google.com/). Make sure you are logged in with the same Google account you used for Firebase, and select your project from the top dropdown menu. (Firebase automatically creates a Google Cloud project for you).

### 2. Configure OAuth Consent Screen
1. On the left menu, go to **APIs & Services** > **OAuth consent screen**.
2. If prompted, select **External** and click Create.
3. Fill in the required fields: App name, User support email, and Developer contact information. You can skip the logo and domains for now.
4. Click **Save and Continue**.
5. On the **Scopes** screen, click "Add or Remove Scopes" and select `.../auth/userinfo.email` and `.../auth/userinfo.profile`. Click Save and Continue.
6. Click **Save and Continue** through the Test Users screen.

### 3. Create Web Client Credentials
1. On the left menu, go to **Credentials**.
2. Click the **+ CREATE CREDENTIALS** button at the top, and select **OAuth client ID**.
3. For the Application type, select **Web application**.
4. Give it a name (e.g., "Supabase Web Client").
5. Scroll down to **Authorized redirect URIs** and click **ADD URI**.
6. **IMPORTANT:** Paste the exact **Callback URL (for OAuth)** provided by Supabase here (e.g., `https://sifkyueyowfwiajdrpmv.supabase.co/auth/v1/callback`).
7. Click **Create**.

### 4. Copy Keys to Supabase
A pop-up will appear showing your new Client ID and Client Secret.

1. **Client ID:** Copy this and paste it into the **"Client IDs"** field in your Supabase Google Auth settings.
2. **Client Secret:** Copy this and paste it into the **"Client Secret (for OAuth)"** field in Supabase.
3. Turn ON the **"Enable Sign in with Google"** toggle at the top of the Supabase settings.
4. Click **Save** in Supabase!

*Note: For the Flutter mobile app to work seamlessly, you don't need separate Android/iOS client IDs in Supabase when using the `signInWithOAuth` web-based redirect flow. The Web Application Client ID handles the routing perfectly.*
