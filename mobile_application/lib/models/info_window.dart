import 'package:google_maps_flutter/google_maps_flutter.dart';

enum InfoWindowType { position, destination, bus }

class CityCabInfoWindow {
  final String? name;
  final Duration? time;
  final LatLng? position;
  final InfoWindowType type;
  final String? licensePlate;

  const CityCabInfoWindow(
      {this.name,
      this.time,
      this.position,
      required this.type,
      this.licensePlate});
}
