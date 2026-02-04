// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../dashboard/presentation/dashboard_screen.dart';
// import '../data/models/user_model.dart';

// class LoginController extends GetxController {
//   final phoneController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   final isLoading = false.obs;

//   // Mock user for now since Firebase setup requires real credentials
//   Rx<UserModel?> currentUser = Rx<UserModel?>(null);

//   void login() async {
//     if (!formKey.currentState!.validate()) return;

//     isLoading.value = true;

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));

//     isLoading.value = false;

//     // Hardcoded logic for demo purposes
//     if (phoneController.text == '123456789') {
//       currentUser.value = UserModel(
//         id: '1',
//         phone: '123456789',
//         role: 'admin',
//         maxOrders: 10,
//         createdAt: DateTime.now(),
//         isActive: true,
//       );
//       Get.snackbar('Success', 'Welcome Admin');
//       Get.offAll(() => const DashboardScreen());
//     } else {
//       currentUser.value = UserModel(
//         id: '2',
//         phone: phoneController.text,
//         role: 'user',
//         maxOrders: 3,
//         createdAt: DateTime.now(),
//         isActive: true,
//       );
//       Get.snackbar('Success', 'Welcome User');
//       Get.offAll(() => const DashboardScreen());
//     }
//   }

//   String? validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     }
//     if (value.length < 9) {
//       return 'Phone number too short';
//     }
//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 chars';
//     }
//     return null;
//   }
// }
