# Flutter Advanced UI and Animations Guide

## 1. Custom Widgets

Creating custom widgets allows you to encapsulate complex UI logic and create reusable components.

### Example: Custom Button Widget

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

// Usage
CustomButton(
  text: 'Press me',
  onPressed: () {
    print('Button pressed!');
  },
)
```

## 2. Themes and Styling

Themes allow you to define a consistent look and feel across your entire app.

### Example: Custom Theme

```dart
import 'package:flutter/material.dart';

ThemeData customTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    accentColor: Colors.orangeAccent,
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

// Usage in main.dart
MaterialApp(
  theme: customTheme(),
  home: MyHomePage(),
)
```

## 3. Responsive Design

Responsive design ensures your app looks good on various screen sizes.

### Example: Using LayoutBuilder

```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return WideLayout();
        } else {
          return NarrowLayout();
        }
      },
    );
  }
}

class WideLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: LeftPanel()),
        Expanded(child: RightPanel()),
      ],
    );
  }
}

class NarrowLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LeftPanel(),
        RightPanel(),
      ],
    );
  }
}
```

## 4. Basic Animations

Flutter provides several ways to create animations. Here's an example using `AnimatedContainer`.

### Example: Animated Container

```dart
class AnimatedContainerExample extends StatefulWidget {
  @override
  _AnimatedContainerExampleState createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        width: _expanded ? 200.0 : 100.0,
        height: _expanded ? 200.0 : 100.0,
        color: _expanded ? Colors.blue : Colors.red,
        child: Center(
          child: Text(_expanded ? 'Expanded!' : 'Tap to expand'),
        ),
      ),
    );
  }
}
```

## 5. Hero Animations

Hero animations create a visual connection between screens, typically used for seamless transitions of images or icons.

### Example: Hero Animation

```dart
// First screen
class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('First Screen')),
      body: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return SecondScreen();
          }));
        },
        child: Hero(
          tag: 'imageHero',
          child: Image.network('https://picsum.photos/250?image=9'),
        ),
      ),
    );
  }
}

// Second screen
class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network('https://picsum.photos/250?image=9'),
          ),
        ),
      ),
    );
  }
}
```

Remember, these are just basic examples. Flutter offers many more advanced animation capabilities, including custom animations using the `Animation` class, `AnimationController`, and `Tween`.

When working with advanced UI and animations, always consider performance implications, especially on lower-end devices. Use tools like the Flutter Performance Profiler to identify and resolve any performance issues.

