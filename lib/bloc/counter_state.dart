import 'package:equatable/equatable.dart';
import 'package:basic_widget/bloc/status.dart';

class CounterState extends Equatable {
  final int counter;
  final bool isLoading;
  final Status status;
  const CounterState({
    required this.counter,
    required this.isLoading,
    required this.status,
  });

  CounterState copyWith({int? counter, bool? isLoading, Status? status}) {
    return CounterState(
      counter: counter ?? this.counter,
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [counter, isLoading, status];
}
