# Creating Your First Flutter App

## Setting Up Your First Project

1. Open your terminal or command prompt.
2. Navigate to the directory where you want to create your project.
3. Run the following command:
   ```
   flutter create my_first_app
   ```
4. Navigate into the project directory:
   ```
   cd my_first_app
   ```

## Understanding the Basic Structure

After creating your project, you'll see the following directory structure:

```
my_first_app/
├── android/
├── ios/
├── lib/
│   └── main.dart
├── test/
├── pubspec.yaml
└── [other configuration files]
```

Key components:

1. **android/** and **ios/**: Platform-specific code and configurations.
2. **lib/**: Contains your Dart code. `main.dart` is the entry point of your app.
3. **test/**: For your app's tests.
4. **pubspec.yaml**: Manages the project's dependencies and assets.

## The main.dart File

Open `lib/main.dart`. This is what you'll see:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

Key points:

1. The `main()` function is the entry point of the app.
2. `MyApp` is a stateless widget that sets up the overall app structure.
3. `MyHomePage` and `_MyHomePageState` create a stateful widget for the home page.
4. The `build` method describes the UI of the app.

## Running Your App

1. Connect a device or start an emulator.
2. In your terminal, run:
   ```
   flutter run
   ```

## Hot Reload and Hot Restart

Flutter offers two powerful features for rapid development: Hot Reload and Hot Restart.

### Hot Reload

- Quickly updates the UI with code changes without losing the app's state.
- Triggered by saving your changes or pressing `r` in the terminal where your app is running.
- Best for UI changes and minor logic updates.

### Hot Restart

- Resets the app's state and reloads it completely.
- Triggered by pressing `R` in the terminal where your app is running.
- Necessary for more significant changes, especially those affecting app initialization.

Try making changes to the `Text` widget in the `build` method and see how quickly your app updates!

