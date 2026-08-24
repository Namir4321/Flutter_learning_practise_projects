import 'package:basic_widget/widgets/counterText.dart';
import 'package:basic_widget/widgets/counterbuttons.dart';
import 'package:flutter/material.dart';

class CounterContent extends StatelessWidget {
  final int counter;

  const CounterContent({
    super.key,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CounterText(counter: counter),

        const SizedBox(height: 20),

        const CounterButtons(),
      ],
    );
  }
}