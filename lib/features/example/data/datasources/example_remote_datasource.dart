import '../../../../core/constants/api_routes.dart';
import '../../../../core/network/dio_client.dart';
import '../models/example_model.dart';

/// Example remote data source interface - Data layer
abstract class ExampleRemoteDataSource {
  Future<List<ExampleModel>> getExamples();
  Future<ExampleModel> getExampleById(String id);
  Future<ExampleModel> createExample(ExampleModel example);
  Future<ExampleModel> updateExample(ExampleModel example);
  Future<void> deleteExample(String id);
}

/// Example remote data source implementation
class ExampleRemoteDataSourceImpl implements ExampleRemoteDataSource {
  final DioClient dioClient;

  ExampleRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ExampleModel>> getExamples() async {
    // Example implementation
    final response = await dioClient.get(ApiRoutes.posts);
    return (response.data as List)
        .map((json) => ExampleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExampleModel> getExampleById(String id) async {
    final response = await dioClient.get(ApiRoutes.postById(id));
    return ExampleModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ExampleModel> createExample(ExampleModel example) async {
    final response = await dioClient.post(
      ApiRoutes.posts,
      data: example.toJson(),
    );
    return ExampleModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ExampleModel> updateExample(ExampleModel example) async {
    final response = await dioClient.put(
      ApiRoutes.postById(example.id),
      data: example.toJson(),
    );
    return ExampleModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExample(String id) async {
    await dioClient.delete(ApiRoutes.postById(id));
  }
}
