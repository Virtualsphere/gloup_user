import 'package:flutter/material.dart';
import 'package:tressy/features/widgets/custom_snackbar.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Cancellation extends StatefulWidget {
  const Cancellation({super.key});

  @override
  State<Cancellation> createState() => _CancellationState();
}

class _CancellationState extends State<Cancellation> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
          },
          onHttpError: (HttpResponseError error) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://gloup.in/privacy-policy')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://gloup.in/cancellation-refund'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(
        title: "Cancellation",
        centerTitle: true,
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: isLoading
          ? const CustomLoadingIndicator()
          : SafeArea(
              child: WebViewWidget(controller: controller),
            ),
    );
  }
}
