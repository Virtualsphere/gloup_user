import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/extensions/string_extensions.dart';

class CustomToast {
  static show(
      BuildContext context, {
        required String title,
        bool isError = false,
      }) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.0),
        color: isError ? AppColors.border : AppColors.primary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isError)
            Icon(
              Icons.check,
              color: isError ? AppColors.primary : AppColors.white,
              size: 18,
            ),
          SizedBox(width: 12.0),
          Flexible(
            child: Text(
              title.capitalize(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isError ? AppColors.primary : AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  const CustomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}

class CustomErrorTextWidget extends StatelessWidget {
  const CustomErrorTextWidget({super.key, required this.title, this.color});

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BodyTextColors(
        title: title,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        isBodoniModa: false,
        color: AppColors.primaryLight,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class NoDataText extends StatelessWidget {
  const NoDataText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HeaderTextBlack(
        title: title,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        isBodoniModa: false,
      ),
    );
  }
}

class NoDataImageWidget extends StatelessWidget {
  const NoDataImageWidget({
    super.key,
    this.imageSize = 150,
    this.top = 0,
  });

  final double imageSize;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: SvgPicture.asset(
          AppImages.noData,
          height: imageSize,
          width: imageSize,
        ),
      ),
    );
  }
}
