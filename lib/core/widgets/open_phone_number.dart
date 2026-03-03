// this file i need win tap on phone its show this option
// 1- call
// 2- send message
// 3- open whatsapp
// 4- open telegram
// 5- copy phone number

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:moamen_project/core/utils/normiliz_eg_phone.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenPhoneNumber extends StatelessWidget {
  final String phone;
  final Widget child;

  const OpenPhoneNumber({Key? key, required this.phone, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String phoneWithCountryCode;
        try {
          phoneWithCountryCode = normalizeEgyptianPhone(phone);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('رقم الهاتف غير صحيح', style: GoogleFonts.cairo()),
              backgroundColor: Colors.redAccent,
            ),
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
                      leading: Icon(Bootstrap.whatsapp, color: Colors.green),
                      title: const Text('واتساب'),
                      onTap: () {
                        launchUrl(
                          Uri.parse('https://wa.me/$phoneWithCountryCode'),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Bootstrap.telegram, color: Colors.blue),
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
