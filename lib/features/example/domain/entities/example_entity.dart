import 'package:equatable/equatable.dart';

/// Example entity - Domain layer
class ExampleEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  const ExampleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, description, createdAt];
}
