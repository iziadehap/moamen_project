import 'package:moamen_project/features/map/data/map_model.dart';

class MapState {
  bool isLoding;
  MapModel mapModel;
  String errorMassage;
  MapState({
    required this.isLoding,
    required this.mapModel,
    required this.errorMassage,
  });

  MapState copyWith({
    bool? isLoding,
    MapModel? mapModel,
    String? errorMassage,
  }) {
    return MapState(
      isLoding: isLoding ?? this.isLoding,
      mapModel: mapModel ?? this.mapModel,
      errorMassage: errorMassage ?? this.errorMassage,
    );
  }
}
