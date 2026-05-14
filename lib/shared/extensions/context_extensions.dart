import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ContextExtensions on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  /// Get keyboard height
  double get keyboardHeight => mediaQuery.viewInsets.bottom;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, isError: true);
  }

  /// Navigate to page
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Navigate and replace current page
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Pop current page
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Check if can pop
  bool get canPop => Navigator.of(this).canPop();

  /// Navigate to a route using GoRouter
  void goTo(String route, {Object? extra}) {
    GoRouter.of(this).go(route, extra: extra);
  }

  /// Navigate to a named route using GoRouter
  void goToNamed(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters,
      Object? extra}) {
    GoRouter.of(this).goNamed(name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
        extra: extra);
  }

  /// Push a route using GoRouter
  Future<T?> pushTo<T extends Object?>(String route, {Object? extra}) {
    return GoRouter.of(this).push<T>(route, extra: extra);
  }

  /// Push a named route using GoRouter
  Future<T?> pushToNamed<T extends Object?>(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters,
      Object? extra}) {
    return GoRouter.of(this).pushNamed<T>(name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
        extra: extra);
  }

  /// Replace current route using GoRouter
  void replaceWith(String route, {Object? extra}) {
    GoRouter.of(this).replace(route, extra: extra);
  }

  /// Replace current named route using GoRouter
  void replaceWithNamed(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters,
      Object? extra}) {
    GoRouter.of(this).replaceNamed(name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
        extra: extra);
  }
}
