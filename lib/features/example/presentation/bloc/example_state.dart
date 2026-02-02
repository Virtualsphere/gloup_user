import 'package:equatable/equatable.dart';
import '../../domain/entities/example_entity.dart';

/// Example states - Presentation layer
abstract class ExampleState extends Equatable {
  const ExampleState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ExampleInitial extends ExampleState {
  const ExampleInitial();
}

/// Loading state
class ExampleLoading extends ExampleState {
  const ExampleLoading();
}

/// Loaded state
class ExamplesLoaded extends ExampleState {
  final List<ExampleEntity> examples;

  const ExamplesLoaded(this.examples);

  @override
  List<Object?> get props => [examples];
}

/// Single example loaded state
class ExampleLoaded extends ExampleState {
  final ExampleEntity example;

  const ExampleLoaded(this.example);

  @override
  List<Object?> get props => [example];
}

/// Example created state
class ExampleCreated extends ExampleState {
  final ExampleEntity example;

  const ExampleCreated(this.example);

  @override
  List<Object?> get props => [example];
}

/// Example updated state
class ExampleUpdated extends ExampleState {
  final ExampleEntity example;

  const ExampleUpdated(this.example);

  @override
  List<Object?> get props => [example];
}

/// Example deleted state
class ExampleDeleted extends ExampleState {
  const ExampleDeleted();
}

/// Error state
class ExampleError extends ExampleState {
  final String message;

  const ExampleError(this.message);

  @override
  List<Object?> get props => [message];
}
