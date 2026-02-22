import 'package:flutter/cupertino.dart';

class CustomIndicator extends StatelessWidget {
  const CustomIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.activeWidth,
    required this.activeColor,
    required this.inActiveColor,
    required this.inactiveWidth,
    required this.borderHeight,
  });

  final int currentIndex;
  final int itemCount;
  final Color activeColor;
  final Color inActiveColor;
  final double activeWidth, inactiveWidth, borderHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: borderHeight,
          width: currentIndex == index ? activeWidth : inactiveWidth,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: currentIndex == index
                ? activeColor
                : inActiveColor,
          ),
        ),
      ),
    );
  }
}