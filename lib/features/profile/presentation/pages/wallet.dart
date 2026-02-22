import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/profile/presentation/pages/profile_page.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';
import 'package:tressy/features/widgets/custom_snackbar.dart';
import 'package:tressy/features/widgets/custom_text_field.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  void initState() {
    super.initState();
  }

  String formatDateTime(String utcString) {
    DateTime utcDateTime = DateTime.parse(utcString);
    DateTime localDateTime = utcDateTime.toLocal();
    return DateFormat('MMM d, yyyy at h:mm a').format(localDateTime);
  }

  String cleanDateTime(String input) {
    return input.replaceAll(RegExp(r'(AM|PM)t'), r'$1').trim();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ActionBar(
              title: 'My Wallet',
              isBackButtonDecoration: true,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15),
                children: [
                  WalletBalanceContainer(
                    amount: '500.00',
                  ),
                  SizedBox(height: 10),
                  HeaderTextBlack(
                    title: 'Transactions',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    isBodoniModa: false,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: NoDataText(title: 'No data found'),
                  ),
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: CustomFullButton(
            title: '+ Add Money',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: DepositBottomSheet(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

String capitalizeWords(String? text) {
  if (text == null || text.isEmpty) return '';
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

// Example:

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.type,
    this.isNegative = false,
  });

  final String title, dateTime, amount, type;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final Color color = isNegative ? AppColors.darkRed : AppColors.greenText;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: HeaderTextBlack(
        title: title,
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: BodyTextHint(
          title: dateTime,
          fontSize: 14,
          fontWeight: FontWeight.w300,
          isSecondary: true,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppIcons.rupeeNormal,
                height: 16,
                width: 16,
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
              ),
              BodyTextColors(
                title: '$amount /-',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: color,
              )
            ],
          ),
          SizedBox(height: 10),
          HeaderTextBlack(
            title: type,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          )
        ],
      ),
    );
  }
}

class DepositBottomSheet extends StatefulWidget {
  const DepositBottomSheet({super.key});

  @override
  State<DepositBottomSheet> createState() => _DepositBottomSheetState();
}

class _DepositBottomSheetState extends State<DepositBottomSheet> {
  final depositFormKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();

  List<String> amounts =
      List.generate(5, (index) => (500 * (index + 1)).toString());

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
      decoration: Themes.bottomSheetDecoration,
      child: SingleChildScrollView(
        child: Form(
          key: depositFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              HeaderTextBlack(
                title: 'Deposit Money',
                fontSize: 24,
                fontWeight: FontWeight.w500,
                isBodoniModa: false,
              ),
              const SizedBox(height: 10),
              BodyTextHint(
                title: 'Securely deposit funds to use for salon bookings',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: amountController,
                hintText: 'Enter Amount to Transfer',
                inputType: TextInputType.number,
                inputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  itemCount: amounts.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          amountController.text = amounts[index];
                        });
                      },
                      child: Container(
                        width: 103,
                        margin:
                            EdgeInsets.fromLTRB(0, 2, index == 4 ? 0 : 15, 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppIcons.rupee,
                              height: 16,
                              width: 16,
                              colorFilter: ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            HeaderTextBlack(
                              title: amounts[index],
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 50),
              CustomFullButton(
                title: 'Deposit',
                isDisabled: amountController.text.isEmpty,
                onTap: () {
                  if (depositFormKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '₹ ${amountController.text} deposited successfully!',
                        ),
                      ),
                    );

                    Navigator.pop(context); // Close bottom sheet
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
