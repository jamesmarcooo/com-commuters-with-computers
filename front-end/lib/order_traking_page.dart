import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_config/flutter_config.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      FlutterConfig.get('GOOGLE_MAPS_API_KEY'), // Your Google Map Key
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track order",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: sourceLocation,
            zoom: 14.5,
          ),
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: const Color(0xFF7B61FF),
              width: 6,
            ),
          },
          markers: {
            const Marker(
              markerId: MarkerId("source"),
              position: sourceLocation,
            ),
            const Marker(
              markerId: MarkerId("destination"),
              position: destination,
            ),
          },
        ));
  }
}
