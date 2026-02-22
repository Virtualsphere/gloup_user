import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';
import 'package:tressy/features/widgets/custom_snackbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
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
              AppBar(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 15.0,bottom: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      height: 35,
                      width: 37,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .2),
                            blurRadius: 20,
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AppIcons.arrowBack,
                          colorFilter: ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                elevation: 0.0,
              ),
              Expanded(child: WebViewWidget(controller: controller),),
            ],
          ),
    );
  }
}
