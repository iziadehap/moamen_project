import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/features/map/presentation/controller/map_notifier.dart';
import 'package:moamen_project/features/map/presentation/controller/map_state.dart';

final mapProvider = NotifierProvider<MapNotifier, MapState>(MapNotifier.new);

