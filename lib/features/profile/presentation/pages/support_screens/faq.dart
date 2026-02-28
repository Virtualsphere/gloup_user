import 'package:flutter/material.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';
import 'package:tressy/features/widgets/custom_snackbar.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
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
            // Prevent redirect loop (optional)
            if (request.url.startsWith('https://gloup.in/privacy-policy')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://gloup.in/faq'));
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: isLoading
          ? const CustomLoadingIndicator()
          : Column(
            children: [
              ProfileAppBar(
                title: "",
                centerTitle: false,
                onBack: () {
                  Navigator.of(context).pop();
                },
              ),
              Expanded(child: WebViewWidget(controller: controller),),
            ],
          ),
    );
  }
}
