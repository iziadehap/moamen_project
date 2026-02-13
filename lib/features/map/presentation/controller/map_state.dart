import 'package:latlong2/latlong.dart';
import 'package:moamen_project/features/map/data/map_model.dart';

class MapState {
  bool isLoding;
  MapModel mapModel;
  String errorMassage;
  LatLng? userLocation;
  bool showPublicCircles;

  MapState({
    required this.isLoding,
    required this.mapModel,
    required this.errorMassage,
    this.userLocation,
    this.showPublicCircles = true,
  });

  MapState copyWith({
    bool? isLoding,
    MapModel? mapModel,
    String? errorMassage,
    LatLng? userLocation,
    bool? showPublicCircles,
  }) {
    return MapState(
      isLoding: isLoding ?? this.isLoding,
      mapModel: mapModel ?? this.mapModel,
      errorMassage: errorMassage ?? this.errorMassage,
      userLocation: userLocation ?? this.userLocation,
      showPublicCircles: showPublicCircles ?? this.showPublicCircles,
    );
  }
}
