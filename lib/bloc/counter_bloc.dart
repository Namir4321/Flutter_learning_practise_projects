import "package:basic_widget/bloc/counter_state.dart";
import "package:basic_widget/bloc/status.dart";
import "package:basic_widget/bloc/user_bloc.dart";
import "package:flutter_bloc/flutter_bloc.dart";

abstract class CounterEvent {}

class IncrementPressed extends CounterEvent {}

class DecrementPressed extends CounterEvent {}

class ResetPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc()
    : super(CounterState(counter: 0, isLoading: false, status: Status.initial)) {
    on<IncrementPressed>((event, emit) {
      emit(state.copyWith(counter: state.counter + 1));
    });
    on<DecrementPressed>((event, emit) {
      if (state.counter > 0) {
        emit(state.copyWith(counter: state.counter - 1,));
      }
    });
    on<ResetPressed>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      await Future.delayed(const Duration(seconds: 2));

      emit(state.copyWith(counter: 0, status: Status.success));
    });
    
  }
}
