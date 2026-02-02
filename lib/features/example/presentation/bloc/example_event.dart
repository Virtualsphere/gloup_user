import 'package:equatable/equatable.dart';
import '../../domain/entities/example_entity.dart';

/// Example events - Presentation layer
abstract class ExampleEvent extends Equatable {
  const ExampleEvent();

  @override
  List<Object?> get props => [];
}

/// Load examples event
class LoadExamplesEvent extends ExampleEvent {
  const LoadExamplesEvent();
}

/// Load example by ID event
class LoadExampleByIdEvent extends ExampleEvent {
  final String id;

  const LoadExampleByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Create example event
class CreateExampleEvent extends ExampleEvent {
  final ExampleEntity example;

  const CreateExampleEvent(this.example);

  @override
  List<Object?> get props => [example];
}

/// Update example event
class UpdateExampleEvent extends ExampleEvent {
  final ExampleEntity example;

  const UpdateExampleEvent(this.example);

  @override
  List<Object?> get props => [example];
}

/// Delete example event
class DeleteExampleEvent extends ExampleEvent {
  final String id;

  const DeleteExampleEvent(this.id);

  @override
  List<Object?> get props => [id];
}
