// this file i need win tap on phone its show this option
// 1- call
// 2- send message
// 3- open whatsapp
// 4- open telegram
// 5- copy phone number

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:icons_plus/icons_plus.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/normiliz_eg_phone.dart';
import 'package:moamen_project/core/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenPhoneNumber extends StatelessWidget {
  final String phone;
  final Widget child;

  const OpenPhoneNumber({super.key, required this.phone, required this.child});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return GestureDetector(
      onTap: () {
        String phoneWithCountryCode;
        try {
          phoneWithCountryCode = normalizeEgyptianPhone(phone);
        } catch (e) {
          showCustomSnackBar(
            context,
            customTheme: customTheme,
            message: 'رقم الهاتف غير صحيح',
            icon: Icons.error,
            isError: true,
            color: customTheme.errorColor,
          );
          return;
        }

        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.call),
                      title: const Text('اتصال'),
                      onTap: () {
                        launchUrl(Uri.parse('tel:$phoneWithCountryCode'));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.message),
                      title: const Text('ارسال رسالة'),
                      onTap: () {
                        launchUrl(Uri.parse('sms:$phoneWithCountryCode'));
                      },
                    ),
                    ListTile(
                      // use icons_plus
                      // why its not grean
                      leading: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                      ),
                      title: const Text('واتساب'),
                      onTap: () {
                        launchUrl(
                          Uri.parse('https://wa.me/$phoneWithCountryCode'),
                        );
                      },
                    ),
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.telegram,
                        color: Colors.blue,
                      ),
                      title: const Text('تليجرام'),
                      onTap: () {
                        launchUrl(
                          Uri.parse('https://t.me/$phoneWithCountryCode'),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.copy),
                      title: const Text('نسخ رقم الهاتف'),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: phone));
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}
