# Flutter Basic Widgets Guide

Flutter provides a rich set of basic widgets that you can use to build your app's user interface. Here are some of the most commonly used basic widgets:

## 1. Text

The `Text` widget displays a string of text with single style.

```dart
Text(
  'Hello, Flutter!',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)
```

## 2. Button

Flutter offers several types of button widgets:

### ElevatedButton

```dart
ElevatedButton(
  child: Text('Press Me'),
  onPressed: () {
    print('Button pressed!');
  },
)
```

### TextButton

```dart
TextButton(
  child: Text('Click Me'),
  onPressed: () {
    print('Text button pressed!');
  },
)
```

### IconButton

```dart
IconButton(
  icon: Icon(Icons.favorite),
  onPressed: () {
    print('Icon button pressed!');
  },
)
```

## 3. Image

The `Image` widget displays an image. Flutter supports various image sources:

### Network Image

```dart
Image.network('https://example.com/image.jpg')
```

### Asset Image

First, add the image to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/my_image.png
```

Then use it in your code:

```dart
Image.asset('assets/my_image.png')
```

## 4. Icon

Flutter provides a set of Material Design icons:

```dart
Icon(
  Icons.star,
  color: Colors.yellow,
  size: 50.0,
)
```

## 5. TextField

`TextField` is used for inputting text:

```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Enter your name',
  ),
  onChanged: (text) {
    print('Current text: $text');
  },
)
```

## 6. Checkbox

`Checkbox` allows the user to select one or more items from a set:

```dart
Checkbox(
  value: true,
  onChanged: (bool? value) {
    // Handle checkbox state change
  },
)
```

## 7. Radio

`Radio` allows the user to select one option from a set:

```dart
Radio<String>(
  value: 'option1',
  groupValue: _selectedOption,
  onChanged: (String? value) {
    setState(() {
      _selectedOption = value!;
    });
  },
)
```

## 8. Switch

`Switch` is used for toggling a single setting on or off:

```dart
Switch(
  value: _lightOn,
  onChanged: (bool value) {
    setState(() {
      _lightOn = value;
    });
  },
)
```

## 9. Slider

`Slider` allows users to select from a range of values:

```dart
Slider(
  value: _currentSliderValue,
  min: 0,
  max: 100,
  divisions: 5,
  label: _currentSliderValue.round().toString(),
  onChanged: (double value) {
    setState(() {
      _currentSliderValue = value;
    });
  },
)
```

## 10. ProgressIndicator

Flutter provides two types of progress indicators:

### Linear Progress Indicator

```dart
LinearProgressIndicator(
  value: 0.7,
)
```

### Circular Progress Indicator

```dart
CircularProgressIndicator(
  value: 0.7,
)
```

Remember, these widgets are often combined and nested to create more complex UI elements. The power of Flutter lies in its composability - you can create sophisticated UIs by combining these simple widgets in various ways.

Also, many of these widgets have numerous properties that allow you to customize their appearance and behavior. Always refer to the Flutter documentation for a complete list of properties and more detailed information on how to use each widget.

