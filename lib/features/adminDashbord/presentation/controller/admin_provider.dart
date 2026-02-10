import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_notifirer.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_state.dart';

final adminProvider = NotifierProvider<AdminNotifier, AdminState>(
  AdminNotifier.new,
);
