import 'package:basic_widget/bloc/counter_bloc.dart';
import 'package:basic_widget/bloc/counter_state.dart';
import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/widgets/countercontent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            if (state.status == Status.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Counter reset successfully')),
              );
            }
          },
          builder: (context, state) {
            return CounterContent(counter: state.counter);
          },
        ),
      ),
    );
  }
}
