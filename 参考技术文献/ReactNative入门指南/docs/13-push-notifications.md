
## Push Notifications in React Native

**1. What are Push Notifications?**

Push notifications are messages sent from a server to a user's device, appearing even when the user isn't actively using the application. They serve as a way to deliver timely, relevant information or re-engage users.

*   **On iOS:** Appear as banners, alerts on the lock screen, and badges on the app icon.
*   **On Android:** Appear in the notification drawer, as heads-up notifications, on the lock screen, and potentially as badges.

**2. Why Use Push Notifications?**

*   **User Engagement:** Bring users back to the app (e.g., new content, promotions, reminders).
*   **Real-time Updates:** Inform users about important events immediately (e.g., new messages, order status changes, alerts).
*   **Transactional Information:** Confirm actions or provide necessary updates (e.g., shipping confirmation, appointment reminders).
*   **Marketing & Promotions:** Announce new features, sales, or events (use sparingly and thoughtfully).

**3. The High-Level Architecture (The Journey of a Push Notification)**

Understanding this flow is essential:

![Diagrammatic Representation](images/Pasted%20image%2020250415183851.png)


1.  **App Registration:** When your React Native app starts, it registers with the device's operating system (iOS or Android) to receive push notifications.
2.  **Token Generation:** The OS communicates with the respective platform's push notification service (APNS for iOS, FCM for Android) and receives a unique **Device Token**. This token acts like an address for sending notifications to *that specific app installation on that specific device*.
3.  **Token Transmission:** Your app receives this Device Token and typically sends it to your backend server.
4.  **Backend Storage:** Your server stores the Device Token, usually associated with a specific user account.
5.  **Sending a Notification:** When an event occurs that should trigger a notification (e.g., a new message for the user), your backend server constructs a **payload** (the notification content: title, body, data) and sends it along with the target user's Device Token(s) to the appropriate platform service (APNS or FCM).
6.  **Platform Delivery:** APNS/FCM validates the request and forwards the notification payload to the target device(s).
7.  **Device Reception:** The device's OS receives the notification.
8.  **App Handling:**
    *   If the app is **killed or in the background**, the OS typically displays the notification directly (banner, lock screen, notification drawer). If the user taps it, the app is launched or brought to the foreground.
    *   If the app is in the **foreground**, the OS usually delivers the notification data directly to the app, allowing you to handle it programmatically (e.g., show an in-app notification, update a badge count).

**4. Key Platform Services:**

*   **APNS (Apple Push Notification Service):** Apple's service for sending notifications to iOS, macOS, tvOS, and watchOS devices. Requires specific certificates and provisioning profiles setup in the Apple Developer portal.
*   **FCM (Firebase Cloud Messaging):** Google's cross-platform messaging solution (successor to GCM). Used for sending notifications to Android devices and can also proxy notifications to APNS for iOS devices, simplifying cross-platform backend logic. Requires setup within a Firebase project.

**5. The Crucial Device Token:**

*   Unique per app install per device.
*   Can expire or change (e.g., app reinstall, OS update, user restores from backup).
*   Your app needs logic to:
    *   Request the token on startup/login.
    *   Detect token refreshes.
    *   Send the latest token to your backend.
*   Your backend needs logic to:
    *   Store tokens securely.
    *   Handle token updates/expirations (FCM/APNS provide feedback if a token is invalid).

**6. React Native Implementation Libraries:**

While you *could* interact with native notification APIs directly via custom native modules, it's complex. Libraries abstract this away:

*   **`@react-native-firebase/app` & `@react-native-firebase/messaging` (Recommended):**
    *   Part of the comprehensive RNFirebase suite, providing a JavaScript bridge to the native Firebase SDKs (both Android and iOS).
    *   Leverages FCM for Android and can use FCM to send to APNS on iOS (or interact with APNS directly).
    *   Well-maintained, feature-rich, and aligns with using other Firebase services (Analytics, Firestore, etc.).
    *   **Requires native setup.**
*   **`react-native-push-notification` (Alternative):**
    *   A community-maintained library.
    *   Can work independently of Firebase (though often used with it).
    *   Supports local notifications (scheduled within the app) and remote push notifications.
    *   **Requires native setup.**

**We will focus on `@react-native-firebase/messaging` as it's a very common and robust choice.**

**7. Setup & Usage (`@react-native-firebase/messaging` - Bare RN)**

This involves JavaScript installation AND native configuration. **Follow the official RNFirebase documentation meticulously, as setup steps can change.**

**Prerequisites:**

*   A Firebase project created on the [Firebase Console](https://console.firebase.google.com/).
*   Bare React Native project initialized (`npx react-native init MyApp`).

**Installation:**

```bash
# Install core Firebase app package
npm install @react-native-firebase/app

# Install messaging package
npm install @react-native-firebase/messaging

# Link native dependencies (iOS)
npx pod-install ios
# or: cd ios && pod install && cd ..
```

**Native Setup (Highly Summarized - Refer to Official Docs):**

*   **Android:**
    1.  Download `google-services.json` from your Firebase project settings and place it in `android/app/`.
    2.  Add `google-services` plugin classpath to `android/build.gradle`.
    3.  Apply the `google-services` plugin in `android/app/build.gradle`.
    4.  Ensure necessary permissions (like `INTERNET`) are in `android/app/src/main/AndroidManifest.xml`.
    5.  (Optional but common) Add Firebase service definitions to `AndroidManifest.xml` if needed for custom background handling beyond the library's defaults.
*   **iOS:**
    1.  Download `GoogleService-Info.plist` from Firebase project settings. Open your project in Xcode (`ios/YourApp.xcworkspace`) and add this file (ensure it's added to the main target).
    2.  **Enable Push Notifications Capability:** In Xcode, go to your App Target > Signing & Capabilities > `+ Capability` > Add "Push Notifications".
    3.  **Enable Background Modes Capability:** Add "Background Modes" capability and check "Remote notifications".
    4.  **APNS Configuration:**
        *   In the Apple Developer Portal, create an APNS key or certificate associated with your App ID (ensure Push Notifications are enabled for the App ID).
        *   Upload this key/certificate to your Firebase Project Settings > Cloud Messaging > Apple app configuration.
    5.  **Modify `AppDelegate.m` / `AppDelegate.mm`:**
        *   Import Firebase: `#import <Firebase.h>`
        *   Configure Firebase in `didFinishLaunchingWithOptions`: `[FIRApp configure];` (should be near the top).
        *   Register for remote notifications: (Code varies slightly depending on setup, check RNFirebase docs - involves `UNUserNotificationCenter` delegate methods like `application:didRegisterForRemoteNotificationsWithDeviceToken:` and `application:didFailToRegisterForRemoteNotificationsWithError:`).
        *   Ensure `didReceiveRemoteNotification` methods forward notifications to Firebase if needed.

**Code Implementation (React Native Side):**

```javascript
// index.js or App.js (Setup background handler EARLY)
import messaging from '@react-native-firebase/messaging';

// Must be registered outside of your component logic, preferably in index.js
messaging().setBackgroundMessageHandler(async remoteMessage => {
  console.log('Message handled in the background!', remoteMessage);
  // --- Handle background data messages here ---
  // You could update AsyncStorage, trigger a local notification, etc.
});


// components/NotificationHandler.js (or inside a main component/hook)
import React, { useEffect } from 'react';
import messaging from '@react-native-firebase/messaging';
import { Alert, PermissionsAndroid, Platform } from 'react-native';

function NotificationHandler() {

  // --- 1. Request Permissions ---
  const requestUserPermission = async () => {
    if (Platform.OS === 'ios') {
      const authStatus = await messaging().requestPermission();
      const enabled =
        authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
        authStatus === messaging.AuthorizationStatus.PROVISIONAL;

      if (enabled) {
        console.log('Authorization status:', authStatus);
        // On iOS, getting permission often triggers token registration automatically
        getFcmToken(); // Try getting token after permission grant
      }
    } else if (Platform.OS === 'android') {
      // Android 13+ requires explicit permission
      try {
         await PermissionsAndroid.request(
             PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS,
         );
         // Older Android versions don't need explicit user permission request via this API
         getFcmToken();
      } catch (err) {
          console.warn('Permission request error:', err);
      }
    }
  };

  // --- 2. Get FCM Token ---
  const getFcmToken = async () => {
    try {
      // Check if registration token already exists
      let currentToken = await messaging().getToken();
      if (currentToken) {
        console.log('FCM Token:', currentToken);
        // **** SEND THIS TOKEN TO YOUR BACKEND SERVER ****
        sendTokenToServer(currentToken);
      }
    } catch (error) {
      console.error('Error getting FCM token:', error);
    }
  };

  // --- Listen for Token Refresh ---
  useEffect(() => {
    const unsubscribe = messaging().onTokenRefresh(newToken => {
      console.log('FCM Token Refreshed:', newToken);
      // **** SEND THIS NEW TOKEN TO YOUR BACKEND SERVER ****
      sendTokenToServer(newToken);
    });
    return unsubscribe; // Unsubscribe on cleanup
  }, []);

  // --- Setup Notification Listeners ---
  useEffect(() => {
    requestUserPermission();

    // --- 3. Handle Foreground Messages ---
    // Triggered when a notification is received while the app is in the foreground
    const unsubscribeForeground = messaging().onMessage(async remoteMessage => {
      console.log('Foreground Message Received:', JSON.stringify(remoteMessage));
      Alert.alert(
        remoteMessage.notification?.title || 'Notification',
        remoteMessage.notification?.body || '',
      );
      // You can display a custom in-app notification UI here
    });

    // --- 4. Handle Notification Opens (Background/Killed) ---
    // Triggered when user taps a notification and the app opens from background state
    const unsubscribeOpened = messaging().onNotificationOpenedApp(remoteMessage => {
      console.log(
        'Notification caused app to open from background state:',
        remoteMessage,
      );
      // Navigate based on notification data, e.g.:
      // if (remoteMessage.data?.screen) {
      //   navigation.navigate(remoteMessage.data.screen, remoteMessage.data.params);
      // }
    });

    // --- Check if app was opened from a KILLED state by a notification ---
    messaging()
      .getInitialNotification()
      .then(remoteMessage => {
        if (remoteMessage) {
          console.log(
            'Notification caused app to open from killed state:',
            remoteMessage,
          );
           // Navigate based on notification data
        }
      });

    // Cleanup listeners on component unmount
    return () => {
        unsubscribeForeground();
        unsubscribeOpened();
    };
  }, []); // Run once on mount

  // Dummy function - replace with your actual API call
  const sendTokenToServer = (token) => {
    console.log(`TODO: Send token ${token} to backend`);
    // fetch('/api/save-token', { method: 'POST', body: JSON.stringify({ token }) });
  }

  return null; // This component doesn't render anything visual
}

export default NotificationHandler;

// Then use <NotificationHandler /> somewhere high up in your app tree, e.g., in App.js
```

**8. The Server-Side Role (Briefly)**

*   **Store Tokens:** Securely store device tokens linked to users.
*   **Construct Payload:** Create the notification object. Common fields:
    *   `notification`: `{ title: string, body: string }` (used by FCM/APNS to automatically display a notification when app is in background/killed).
    *   `data`: `{ key: string, value: string, ... }` (custom key-value pairs, always delivered to your app's handlers - `onMessage`, `setBackgroundMessageHandler`, etc.). Used for routing, passing IDs, etc.
    *   Platform-specific options (e.g., `android.channelId`, `apns.headers`, sound, badge count).
*   **Send Request:** Make an authenticated HTTP POST request to the FCM API endpoint (Firebase Admin SDK is recommended) or directly to the APNS API, including the target token(s) and the payload.
*   **Handle Feedback:** Process responses from FCM/APNS to identify and remove invalid/expired tokens from your database.

**9. Testing:**

*   **Real Devices are Essential:** Push notifications often don't work fully (or at all) on iOS simulators. Android emulators generally work better but real devices are always the definitive test.
*   **Firebase Console:** You can send test messages directly from the Firebase Console Cloud Messaging section to specific FCM tokens.
*   **Backend Tools:** Use tools like Postman or write scripts using Admin SDKs to test sending from your backend logic.

**10. Best Practices & Considerations:**

*   **Ask for Permission Wisely:** Don't ask immediately on app launch. Explain *why* you need permission in context before triggering the native prompt.
*   **Provide Value:** Ensure notifications are relevant, timely, and useful. Avoid spamming.
*   **Frequency Capping:** Limit the number of notifications a user receives in a given period.
*   **User Preferences:** Allow users to customize the types of notifications they receive within your app's settings.
*   **Deep Linking:** When a user taps a notification, take them directly to the relevant content within your app, not just the home screen. Use the `data` payload for this.
*   **Token Management:** Implement robust logic for handling token registration, refresh, and removal on both client and server.
*   **Security:** Protect your server keys (FCM Server Key, APNS Auth Key). Never embed them in the client app.
*   **Payload Size Limits:** Be aware of payload size limits (e.g., APNS: 4KB, FCM: 4KB for notification, potentially more for data-only).


---


# Summary

1.  **Getting Permission & an Address:** First, when your app starts (or at a sensible time), it needs to ask the user, 'Hey, is it cool if I send you notifications?' If the user says yes, the app then asks the phone's operating system (iOS or Android) to register it for notifications. The OS talks to Apple's (APNS) or Google's (FCM) servers, and gets back a unique **Device Token**. Think of this token like a specific mailing address for *your app installation* on *that specific phone*.
2.  **Telling Your Server the Address:** Your app gets this special token and usually sends it immediately to *your backend server*. Your server needs to save this token, probably linking it to the user's account (so you know who to send messages to later).
3.  **Sending the Message:** Now, let's say something happens on your server – maybe a user gets a new message, or an order ships. Your backend decides, 'Okay, I need to tell User X about this.' It creates the notification message (the title, the body, maybe some hidden data) and sends this message *plus the user's saved Device Token* to the correct platform service (APNS for iPhones, FCM for Androids).
4.  **Delivery Service:** Apple's or Google's servers (APNS/FCM) act like the post office. They take the message and the address (token) and deliver it to the user's actual phone over the internet.
5.  **Phone Receives & Shows:** The phone's OS gets the notification.
    *   If your app is **closed or in the background**, the phone usually shows the notification directly (as a banner, on the lock screen, etc.).
    *   If your app is **open and in the foreground**, the notification data is often delivered *silently* to your app code, letting *you* decide how to display it (maybe an in-app banner, or just updating a badge).
6.  **Handling Taps:** If the user taps the notification (when the app was closed/backgrounded), the phone opens your app. Your app needs code to check, 'Hey, was I just opened by a notification?' and if so, maybe navigate the user to the relevant screen (like the new message or order details).

**In React Native:** We usually don't handle all the tricky native registration and listening code ourselves. We use libraries like **`@react-native-firebase/messaging`** which gives us JavaScript functions to:
*   Request permission.
*   Get the device token (to send to our backend).
*   Listen for incoming messages (when the app is foreground).
*   Listen for notification taps (when opened from background/killed).
*   Set up a handler for background messages (less common for simple apps).

  ---

