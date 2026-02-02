import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_examples_usecase.dart';
import 'example_event.dart';
import 'example_state.dart';

/// Example BLoC - Presentation layer
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final GetExamplesUseCase getExamplesUseCase;
  // Add other use cases as needed

  ExampleBloc({
    required this.getExamplesUseCase,
  }) : super(const ExampleInitial()) {
    on<LoadExamplesEvent>(_onLoadExamples);
    on<LoadExampleByIdEvent>(_onLoadExampleById);
    on<CreateExampleEvent>(_onCreate);
    on<UpdateExampleEvent>(_onUpdate);
    on<DeleteExampleEvent>(_onDelete);
  }

  /// Handle load examples event
  Future<void> _onLoadExamples(
    LoadExamplesEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    final result = await getExamplesUseCase();

    result.fold(
      (failure) => emit(ExampleError(failure.message)),
      (examples) => emit(ExamplesLoaded(examples)),
    );
  }

  /// Handle load example by ID event
  Future<void> _onLoadExampleById(
    LoadExampleByIdEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    // TODO: Implement with GetExampleByIdUseCase
    emit(const ExampleError('Not implemented'));
  }

  /// Handle create example event
  Future<void> _onCreate(
    CreateExampleEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    // TODO: Implement with CreateExampleUseCase
    emit(const ExampleError('Not implemented'));
  }

  /// Handle update example event
  Future<void> _onUpdate(
    UpdateExampleEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    // TODO: Implement with UpdateExampleUseCase
    emit(const ExampleError('Not implemented'));
  }

  /// Handle delete example event
  Future<void> _onDelete(
    DeleteExampleEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleLoading());

    // TODO: Implement with DeleteExampleUseCase
    emit(const ExampleError('Not implemented'));
  }
}
