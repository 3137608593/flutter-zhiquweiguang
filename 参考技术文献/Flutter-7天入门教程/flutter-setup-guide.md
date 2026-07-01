# Flutter Development Environment Setup Guide

## Installing Flutter SDK

1. **Download Flutter SDK**:
   - Visit the official Flutter website: https://flutter.dev/docs/get-started/install
   - Choose your operating system and download the Flutter SDK.

2. **Extract the downloaded file**:
   - Choose a location on your computer where you want to install Flutter.
   - Extract the downloaded zip file into this location.

3. **Add Flutter to your PATH**:
   - Add the `flutter/bin` directory to your PATH environment variable.
   - This allows you to run Flutter commands from any terminal window.

4. **Run flutter doctor**:
   - Open a terminal/command prompt.
   - Run `flutter doctor`.
   - This command checks your environment and displays a report of the status of your Flutter installation.

## Configuring IDE

### Option 1: Visual Studio Code

1. **Install VS Code**:
   - Download and install VS Code from https://code.visualstudio.com/

2. **Install Flutter and Dart extensions**:
   - Open VS Code.
   - Go to the Extensions view (Ctrl+Shift+X).
   - Search for "Flutter" and install the official Flutter extension.
   - This will also install the Dart extension.

3. **Verify setup**:
   - Open the Command Palette (Ctrl+Shift+P).
   - Type "Flutter: New Project" and select it.
   - If everything is set up correctly, this should create a new Flutter project.

### Option 2: Android Studio

1. **Install Android Studio**:
   - Download and install Android Studio from https://developer.android.com/studio

2. **Install Flutter and Dart plugins**:
   - Open Android Studio.
   - Go to File > Settings (on Mac, Android Studio > Preferences).
   - Select Plugins in the left panel.
   - Search for and install the Flutter plugin.
   - This will also install the Dart plugin.

3. **Configure Flutter SDK path**:
   - Go to File > Settings (on Mac, Android Studio > Preferences).
   - Select Languages & Frameworks > Flutter in the left panel.
   - Enter the path to your Flutter SDK.

4. **Verify setup**:
   - Restart Android Studio.
   - Go to File > New > New Flutter Project.
   - If everything is set up correctly, this should allow you to create a new Flutter project.

## Additional Setup

1. **Set up Android SDK** (for Android development):
   - Install Android SDK through Android Studio.
   - Configure an Android emulator or connect a physical Android device.

2. **Set up Xcode** (for iOS development, Mac only):
   - Install Xcode from the Mac App Store.
   - Set up the iOS simulator or connect a physical iOS device.

3. **Set up web development**:
   - Ensure you have Chrome installed for web development and debugging.

## Verifying Installation

After completing the setup, run `flutter doctor` again in the terminal. It should show that everything is set up correctly. If there are any issues, `flutter doctor` will provide information on how to resolve them.

