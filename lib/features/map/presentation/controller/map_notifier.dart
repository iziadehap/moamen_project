import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/error/failure.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/map/data/datasources/map_datasources.dart';
import 'package:moamen_project/features/map/data/map_model.dart';
import 'package:moamen_project/features/map/data/map_reboimp.dart';
import 'package:moamen_project/features/map/domain/mapUsecase/map_getOrders.dart';
import 'package:moamen_project/features/map/domain/mapUsecase/map_sort.dart';
import 'package:moamen_project/features/map/presentation/controller/map_state.dart';

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() {
    return MapState(
      isLoding: false,
      mapModel: MapModel(userPoints: [], publicPoints: []),
      errorMassage: "",
    );
  }

  Future<void> getOrders() async {
    state = state.copyWith(isLoding: true);
    // get user data
    final authState = ref.read(authProvider);
    final user = authState.user;

    // get orders
    final mapDatasources = MapDatasources();
    final mapRebo = MapReboImp(mapDatasources: mapDatasources);
    final mapUsecase = GetOrders(mapRebo: mapRebo);
    final result = await mapUsecase.call(user!);

    result.fold(
      (failure) {
        state = state.copyWith(isLoding: false, errorMassage: failure.message);
      },
      (mapModel) async {
        final location = await getUserLocation();
        location.fold(
          (failure) {
            state = state.copyWith(
              isLoding: false,
              errorMassage: failure.message,
            );
          },
          (location) {
            sortOrdersByLocation(location, mapModel);
          },
        );
        // state = state.copyWith(isLoding: false, mapModel: mapModel);
      },
    );
  }

  Future<void> sortOrdersByLocation(LatLng location, MapModel mapModel) async {
    state = state.copyWith(isLoding: true);
    // sort orders
    final mapDatasources = MapDatasources();
    final mapRebo = MapReboImp(mapDatasources: mapDatasources);
    final mapUsecase = SortOrdersByLocation(mapRebo: mapRebo);
    final result = await mapUsecase.call(location, mapModel);

    result.fold(
      (failure) {
        state = state.copyWith(isLoding: false, errorMassage: failure.message);
      },
      (mapModel) {
        state = state.copyWith(isLoding: false, mapModel: mapModel);
      },
    );
  }

  Future<Either<Failure, LatLng>> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      await Future.delayed(const Duration(seconds: 2));
      if (permission == LocationPermission.denied) {
        return Left(Failure(message: "الرجاء تفعيل الموقع"));
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return Right(LatLng(position.latitude, position.longitude));
  }
}
