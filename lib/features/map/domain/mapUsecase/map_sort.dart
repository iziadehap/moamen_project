import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/error/failure.dart';
import 'package:moamen_project/features/map/data/map_model.dart';
import 'package:moamen_project/features/map/domain/map_rebo.dart';

class SortOrdersByLocation {
  final MapRebo mapRebo;
  SortOrdersByLocation({required this.mapRebo});
  Future<Either<Failure, MapModel>> call(
    LatLng location,
    MapModel mapModel,
  ) async {
    try {
      const distance = Distance();

      // Sort userPoints (individual orders)
      mapModel.userPoints.sort((a, b) {
        if (a.latitude == null || a.longitude == null) return 1;
        if (b.latitude == null || b.longitude == null) return -1;

        final distA = distance(location, LatLng(a.latitude!, a.longitude!));
        final distB = distance(location, LatLng(b.latitude!, b.longitude!));
        return distA.compareTo(distB);
      });

      // // Sort publicPoints (circles)
      // mapModel.publicPoints.sort((a, b) {
      //   final distA = distance(location, a.points);
      //   final distB = distance(location, b.points);
      //   return distA.compareTo(distB);
      // });

      return Right(mapModel);
    } catch (e) {
      return Left(
        Failure(code: e.toString(), message: "error when sort orders"),
      );
    }
  }
}
