import 'package:latlong2/latlong.dart';
import 'package:moamen_project/features/map/data/map_model.dart';

class MapState {
  bool isLoding;
  MapModel mapModel;
  String errorMassage;
  String hintMassage;
  LatLng? userLocation;
  bool showPublicCircles;

  // ✅ جديد: نقاط المسار للرسم
  List<LatLng> routePoints;

  MapState({
    required this.isLoding,
    required this.mapModel,
    required this.errorMassage,
    required this.hintMassage,
    this.userLocation,
    this.showPublicCircles = true,
    this.routePoints = const [],
  });

  MapState copyWith({
    bool? isLoding,
    MapModel? mapModel,
    String? errorMassage,
    String? hintMassage,
    LatLng? userLocation,
    bool? showPublicCircles,
    List<LatLng>? routePoints,
  }) {
    return MapState(
      isLoding: isLoding ?? this.isLoding,
      mapModel: mapModel ?? this.mapModel,
      errorMassage: errorMassage ?? this.errorMassage,
      hintMassage: hintMassage ?? this.hintMassage,
      userLocation: userLocation ?? this.userLocation,
      showPublicCircles: showPublicCircles ?? this.showPublicCircles,
      routePoints: routePoints ?? this.routePoints,
    );
  }
}
