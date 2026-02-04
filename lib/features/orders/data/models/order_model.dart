import 'package:latlong2/latlong.dart';

class OrderModel {
  final String id;
  final String address;
  final LatLng location; // Using LatLng for easier map integration
  final String status; // 'pending' or 'delivered'
  final DateTime createdAt;

  // Transient property for distance calculation
  double? distanceInMeters;

  OrderModel({
    required this.id,
    required this.address,
    required this.location,
    required this.status,
    required this.createdAt,
    this.distanceInMeters,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data) {
    // Supabase returns standard JSON types
    // Assuming location is stored as {lat: ..., lng: ...} jsonb or two columns
    // If it's a PostGIS point, parsing might be different.
    // For simplicity, let's assume 'lat' and 'lng' double columns or keys.

    double lat = (data['lat'] ?? 0.0).toDouble();
    double lng = (data['lng'] ?? 0.0).toDouble();

    // If using a json column named 'location'
    if (data['location'] != null && data['location'] is Map) {
      lat = (data['location']['lat'] ?? 0.0).toDouble();
      lng = (data['location']['lng'] ?? 0.0).toDouble();
    }

    return OrderModel(
      id: data['id'].toString(), // Supabase IDs can be int or UUID
      address: data['address'] ?? '',
      location: LatLng(lat, lng),
      status: data['status'] ?? 'pending',
      createdAt:
          DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'lat': location.latitude,
      'lng': location.longitude,
      'status': status,
      // created_at usually handled by DB default
    };
  }
}
