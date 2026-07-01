# Flutter Widgets and Layouts Guide

## 1. Stateless and Stateful Widgets

### Stateless Widgets
- Immutable widgets that don't store any state.
- Used for UI parts that don't change dynamically.

```dart
class MyStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello, I am a stateless widget!'),
    );
  }
}
```

### Stateful Widgets
- Mutable widgets that can change their state during the lifetime of the widget.
- Used for UI parts that need to change dynamically.

```dart
class MyStatefulWidget extends StatefulWidget {
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Counter: $_counter'),
    );
  }
}
```

## 2. Basic Widgets

### Text
```dart
Text(
  'Hello, Flutter!',
  style: TextStyle(fontSize: 24, color: Colors.blue),
)
```

### Button
```dart
ElevatedButton(
  onPressed: () {
    // Button action
  },
  child: Text('Click me'),
)
```

### Image
```dart
Image.network('https://example.com/image.jpg')
```

## 3. Layout Widgets

### Container
- A convenience widget that combines common painting, positioning, and sizing widgets.

```dart
Container(
  width: 200,
  height: 200,
  color: Colors.blue,
  child: Text('Hello'),
)
```

### Row
- Arranges its children in a horizontal array.

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: <Widget>[
    Icon(Icons.star),
    Icon(Icons.star),
    Icon(Icons.star),
  ],
)
```

### Column
- Arranges its children in a vertical array.

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
    Text('Hello'),
    Text('World'),
    Text('!'),
  ],
)
```

## 4. Stack and Positioned Widgets

### Stack
- Allows widgets to overlap.

### Positioned
- Controls the position of a child within a Stack.

```dart
Stack(
  children: <Widget>[
    Container(
      width: 300,
      height: 300,
      color: Colors.red,
    ),
    Positioned(
      top: 80,
      left: 80,
      child: Container(
        width: 150,
        height: 150,
        color: Colors.blue,
      ),
    ),
  ],
)
```

## 5. ListView and GridView

### ListView
- Displays its children in a scrollable list.

```dart
ListView(
  children: <Widget>[
    ListTile(
      leading: Icon(Icons.map),
      title: Text('Map'),
    ),
    ListTile(
      leading: Icon(Icons.photo_album),
      title: Text('Album'),
    ),
    ListTile(
      leading: Icon(Icons.phone),
      title: Text('Phone'),
    ),
  ],
)
```

### GridView
- Displays its children in a scrollable grid.

```dart
GridView.count(
  crossAxisCount: 2,
  children: List.generate(100, (index) {
    return Center(
      child: Text(
        'Item $index',
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }),
)
```

Remember, these widgets can be nested and combined in various ways to create complex layouts. Practice and experimentation are key to mastering Flutter layouts!

