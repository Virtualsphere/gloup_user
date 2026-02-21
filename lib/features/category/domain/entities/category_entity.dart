import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String label;
  final String imageUrl;

  const CategoryEntity({
    required this.id,
    required this.label,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, label, imageUrl];
}
