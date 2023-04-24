import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:front_end_mobile/projectConfig.dart' as config;
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late bool _serviceEnabled;

  late PermissionStatus _permissionGranted;
  late LocationData _userlocationData;
  late LatLng _busLocation;
  late LatLng _userLocation;
  Timer? timer;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  late GoogleMapController _googlemapController;
  Location location = new Location();
  PolylinePoints polylinePoints = PolylinePoints();

  Marker busMarker =
      Marker(markerId: MarkerId('default1'), position: LatLng(29, 19.0));
  Marker userMarker =
      Marker(markerId: MarkerId('default2'), position: LatLng(27, 19.0));

  int Bus_id = 4;

  static final CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 11.4746,
  );

  void getUserLocation() async {
    print("getting user location");
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("##############location service not enabled###################");
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print(
            "##############location permission not granted###################");
        return;
      }
    }
    var currentUserLocation = await location.getLocation();
    print("###########current user location################");

    setState(() {
      _userlocationData = currentUserLocation;
      print(
          "*********** User Location Data : ${_userlocationData} **************");
      _userLocation = LatLng(_userlocationData.latitude ?? 0.0,
          _userlocationData.longitude ?? 0.0);
      userMarker = Marker(
          markerId: MarkerId("Me"),
          infoWindow: const InfoWindow(title: "Me"),
          position: _userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
    });
  }

  void getBusLocation() async {
    print("getting the live location of bus");
    var response = await http.post(
      Uri.http(config.BaseUrl, "locations"),
      body: jsonEncode({
        "Bus_id": Bus_id,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    setState(() {
      var result = jsonDecode(response.body);

      _busLocation =
          LatLng(double.parse(result['Lat']), double.parse(result['Long']));
      print("*********** Bus Cordinates : ${_busLocation} *************");
      busMarker = Marker(
          markerId: MarkerId("Bus"),
          infoWindow: const InfoWindow(title: "Bus"),
          position: _busLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
    });
  }

  _getPolyline() async {
    print("###############getting the polyline####################");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyDWDkA6pznAi2drXguPOyPXw6Pf7KIccR0",
        PointLatLng(_busLocation.latitude, _busLocation.longitude),
        PointLatLng(_userLocation.latitude, _userLocation.longitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    print(
        "############# Poly points ################## ${polylineCoordinates}");
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 4,
      zIndex: 1,
    );
    polylines[id] = polyline;
    print("############## Drawing Polyline #################");
    print("######### ${polylines.values} #############");
    setState(() {});
  }

  void callFunction() {
    getUserLocation();
    getBusLocation();
    _getPolyline();
  }

  @override
  void initState() {
    // getUserLocation();
    // getBusLocation();
    // _getPolyline();
    super.initState();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) => callFunction());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        centerTitle: false,
        title: Text("Live Bus Location", style: TextStyle(color: Colors.black)),
      ),
      body: GoogleMap(
        polylines: Set<Polyline>.of(polylines.values),
        markers: {userMarker, busMarker},
        initialCameraPosition: initialCameraPosition,
        mapType: MapType.normal,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) =>
            _googlemapController = controller,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              heroTag: "Bus",
              backgroundColor: Color(0xff90be6d),
              onPressed: () {
                _googlemapController.animateCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                        target: _busLocation, tilt: 50.0, zoom: 14.8)));
              },
              child: Text("Bus")),
          SizedBox(height: 10),
          FloatingActionButton(
              heroTag: "Me",
              backgroundColor: Colors.redAccent,
              onPressed: () {
                _googlemapController.animateCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                        target: _userLocation, tilt: 50.0, zoom: 14.8)));
              },
              child: Text("Me"))
        ],
      ),
    );
  }
}
