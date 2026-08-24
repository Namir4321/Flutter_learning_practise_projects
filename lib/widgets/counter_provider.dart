import 'package:flutter/widgets.dart';

class CounterProvider extends InheritedWidget {
  final int counter;
  final VoidCallbackAction increment;
  final VoidCallbackAction decrement;
  const CounterProvider({
    super.key,
    required this.counter,
    required this.increment,
    required this.decrement,
    required super.child,
  });

  static CounterProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>()!;
  }

  @override
  bool updateShouldNotify(CounterProvider oldWidget) {
    return oldWidget.counter != counter;
  }
}
