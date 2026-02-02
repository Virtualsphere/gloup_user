import '../../domain/entities/example_entity.dart';

/// Example model - Data layer
class ExampleModel extends ExampleEntity {
  const ExampleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
  });

  /// From JSON
  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// From entity
  factory ExampleModel.fromEntity(ExampleEntity entity) {
    return ExampleModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }

  /// Copy with
  ExampleModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
