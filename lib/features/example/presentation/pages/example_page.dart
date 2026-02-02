import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_widget.dart';
import '../bloc/example_bloc.dart';
import '../bloc/example_event.dart';
import '../bloc/example_state.dart';

/// Example page - Presentation layer
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ExampleBloc>()..add(const LoadExamplesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Examples'),
        ),
        body: BlocBuilder<ExampleBloc, ExampleState>(
          builder: (context, state) {
          if (state is ExampleLoading) {
            return const LoadingWidget(message: 'Loading examples...');
          }

          if (state is ExampleError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<ExampleBloc>().add(const LoadExamplesEvent());
              },
            );
          }

          if (state is ExamplesLoaded) {
            if (state.examples.isEmpty) {
              return const EmptyWidget(
                message: 'No examples found',
                icon: Icons.inbox_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ExampleBloc>().add(const LoadExamplesEvent());
              },
              child: ListView.builder(
                padding: AppSizes.paddingAll,
                itemCount: state.examples.length,
                itemBuilder: (context, index) {
                  final example = state.examples[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.marginM),
                    child: ListTile(
                      title: Text(example.title),
                      subtitle: Text(example.description),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to detail page
                      },
                    ),
                  );
                },
              ),
            );
          }

            return const EmptyWidget(
              message: 'Pull to refresh',
              icon: Icons.refresh,
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to create page
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
