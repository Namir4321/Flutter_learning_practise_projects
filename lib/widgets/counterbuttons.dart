import 'package:basic_widget/bloc/counter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterButtons extends StatelessWidget {
  const CounterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<CounterBloc>().add(IncrementPressed());
          },
          child: const Text('+ Increment'),
        ),

        const SizedBox(width: 12),

        ElevatedButton(
          onPressed: () {
            context.read<CounterBloc>().add(DecrementPressed());
          },
          child: const Text('- Decrement'),
        ),
      ],
    );
  }
}
