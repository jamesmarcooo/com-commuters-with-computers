import 'dart:async';
import 'dart:typed_data';

import 'package:mobile_application/constant/google_map_key.dart';
import 'package:mobile_application/models/address.dart';
import 'package:mobile_application/models/info_window.dart';
import 'package:mobile_application/models/user.dart';
import 'package:mobile_application/repositories/user_repository.dart';
import 'package:mobile_application/ui/info_window/custom_info_window.dart';
import 'package:mobile_application/ui/info_window/custom_widow.dart';
import 'package:mobile_application/utils/images_assets.dart';
import 'package:mobile_application/constant/my_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:convert';

import 'code_generator.dart';

class Deley {
  final int? milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Deley({this.milliseconds});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(microseconds: milliseconds ?? 400), action);
  }
}

class MapService {
  MapService._();

  static MapService? _instance;

  static MapService? get instance {
    if (_instance == null) {
      _instance = MapService._();
    }
    return _instance;
  }

  final String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";

  StreamSubscription<Position>? positionStream;

  Duration duration = Duration();
  final _deley = Deley(milliseconds: 5000);

  String get getUserMapIcon {
    Roles? userRoles = UserRepository.instance.currentUserRole;
    return (() {
      if (userRoles == Roles.driver) {
        return ImagesAsset.bus;
      } else {
        return ImagesAsset.circlePin;
      }
    })();
  }

  String get getDriverMapIcon {
    return ImagesAsset.bus;
  }

  void dispose() {
    positionStream?.cancel();
  }

  ValueNotifier<Address?> currentPosition = ValueNotifier<Address?>(null);
  ValueNotifier<List<Marker>> markers = ValueNotifier<List<Marker>>([]);
  List<Address> searchedAddress = [];

  CustomInfoWindowController controller = CustomInfoWindowController();

  Future<Address?> getCurrentPosition() async {
    final check = await requestAndCheckPermission();
    if (check == true) {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      final address = await getAddressFromCoodinate(
          LatLng(position.latitude, position.longitude));

      final icon = await getMapIcon(getUserMapIcon);
      await addMarker(address, icon,
          time: DateTime.now(), type: InfoWindowType.position);

      print(address.toString());
      currentPosition.value = address;

      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      currentPosition.notifyListeners();
      return currentPosition.value;
    } else {
      return null;
    }
  }

  Stream<void> listenToPositionChanges(
      {required Function(Address?) eventFiring}) async* {
    final check = await requestAndCheckPermission();
    if (check) {
      print('started location');

      //get positionStream using Geolocator and its getPositionStream method
      positionStream =
          Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
              .asStream()
              .listen((position) async {
        eventFiring(currentPosition.value);

        late LocationSettings locationSettings;
        locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 5);

        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) async {
          print(position == null
              ? 'Unknown'
              : '${position.latitude.toString()}, ${position.longitude.toString()}');

          currentPosition.value = await getAddressFromCoodinate(
              LatLng(position!.latitude, position.longitude));

          final icon = await getMapIcon(getUserMapIcon);
          await addMarker(currentPosition.value, icon,
              time: DateTime.now(),
              type: InfoWindowType.position,
              position: position);
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          currentPosition.notifyListeners();
        });
        print('updating location');
      });
    }
  }

  Future<Address> getAddressFromCoodinate(LatLng latLng,
      {List<PointLatLng>? polylines, String? id}) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final placemark = placemarks.first;
    final address = Address(
      id: id ?? UserRepository.instance.currentUser?.uid ?? '',
      street: placemark.street ?? '',
      city: placemark.locality ?? '',
      state: placemark.administrativeArea ?? '',
      country: placemark.country ?? '',
      latLng: latLng,
      polylines: polylines ?? [],
      postcode: placemark.postalCode ?? '',
    );
    return address;
  }

  Future<List<Address>> getAddressFromQuery(String query) async {
    if (query.length > 3) {
      _deley.run(() async {
        try {
          final locations = await locationFromAddress(query);
          for (var i = 0; i < locations.length; i++) {
            final location = locations[i];
            List<Placemark> placemarks = await placemarkFromCoordinates(
                location.latitude, location.longitude);
            for (var i = 0; i < placemarks.length; i++) {
              final placemark = placemarks[i];
              final address = Address(
                id: CodeGenerator.instance!.generateCode('m'),
                street: placemark.street ?? '',
                city: placemark.locality ?? '',
                state: placemark.administrativeArea ?? '',
                country: placemark.country ?? '',
                latLng: LatLng(location.latitude, location.longitude),
                polylines: [],
                postcode: placemark.postalCode ?? '',
              );
              searchedAddress.add(address);
            }
          }
        } catch (e, stackTrace) {
          print('Failed to get address: $e');
          print('Stack trace: $stackTrace');
        }
      });
    }
    return searchedAddress;
  }

  Future<Address?> getPosition(LatLng latLng) async {
    final address = await getAddressFromCoodinate(latLng);

    markers.value.clear();
    controller.hideInfoWindow!();

    final icon = await getMapIcon(getUserMapIcon);
    await addMarker(address, icon,
        time: DateTime.now(), type: InfoWindowType.position);
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    currentPosition.notifyListeners();

    return address;
  }

  Future<Address> getRouteCoordinates(
      LatLng? startLatLng, LatLng? endLatLng) async {
    markers.value.clear();

    var uri = Uri.parse(
        "$baseUrl?origin=${startLatLng?.latitude},${startLatLng?.longitude}&destination=${endLatLng?.latitude},${endLatLng?.longitude}&key=${GoogleMapKey.key}");
    http.Response response = await http.get(uri);
    Map values = jsonDecode(response.body);
    final points = values['routes'][0]['overview_polyline']['points'];
    final legs = values['routes'][0]['legs'];
    final polylines = PolylinePoints().decodePolyline(points);

    if (legs != null) {
      final DateTime time = DateTime.fromMillisecondsSinceEpoch(
          values['routes'][0]['legs'][0]['duration']['value']);
      duration = DateTime.now().difference(time);
    }
    Address endAddress =
        await _getEndAddressAndAddMarkers(startLatLng, endLatLng, polylines);

    /// Get our end address
    return endAddress;
  }

  Future<Address> _getEndAddressAndAddMarkers(LatLng? startLatLng,
      LatLng? endLatLng, List<PointLatLng> polylines) async {
    final endAddress = await getAddressFromCoodinate(
        LatLng(endLatLng!.latitude, endLatLng.longitude),
        polylines: polylines,
        id: CodeGenerator.instance?.generateCode('m'));

    BitmapDescriptor icon = await getMapIcon(ImagesAsset.pin);
    await addMarker(endAddress, icon,
        time: DateTime.now(), type: InfoWindowType.destination);

    final startAddress = await getAddressFromCoodinate(
        LatLng(startLatLng!.latitude, startLatLng.longitude),
        polylines: polylines);

    BitmapDescriptor startMapIcon = await getMapIcon(getUserMapIcon);
    await addMarker(startAddress, startMapIcon,
        time: DateTime.now(), type: InfoWindowType.position);

    currentPosition.value = startAddress;
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    currentPosition.notifyListeners();

    return endAddress;
  }

  Future<Address> getBusRouteCoordinates(
      LatLng? startLatLng, LatLng? endLatLng) async {
    markers.value.clear();

    var uri = Uri.parse(
        "$baseUrl?origin=${startLatLng?.latitude},${startLatLng?.longitude}&destination=${endLatLng?.latitude},${endLatLng?.longitude}&key=${GoogleMapKey.key}");
    http.Response response = await http.get(uri);
    Map values = jsonDecode(response.body);
    final points = values['routes'][0]['overview_polyline']['points'];
    final legs = values['routes'][0]['legs'];
    final polylines = PolylinePoints().decodePolyline(points);

    if (legs != null) {
      final DateTime time = DateTime.fromMillisecondsSinceEpoch(
          values['routes'][0]['legs'][0]['duration']['value']);
      duration = DateTime.now().difference(time);
    }
    Address endAddress =
        await _getBusEndAddressAndAddMarkers(startLatLng, endLatLng, polylines);

    /// Get our end address
    return endAddress;
  }

  Future<Address> _getBusEndAddressAndAddMarkers(LatLng? startLatLng,
      LatLng? endLatLng, List<PointLatLng> polylines) async {
    final endAddress = await getAddressFromCoodinate(
        LatLng(endLatLng!.latitude, endLatLng.longitude),
        polylines: polylines,
        id: CodeGenerator.instance?.generateCode('m'));

    BitmapDescriptor icon = await getMapIcon(getUserMapIcon);
    await addMarker(endAddress, icon,
        time: DateTime.now(), type: InfoWindowType.destination);

    final startAddress = await getAddressFromCoodinate(
        LatLng(startLatLng!.latitude, startLatLng.longitude),
        polylines: polylines);

    BitmapDescriptor startMapIcon = await getMapIcon(getDriverMapIcon);
    await addMarker(startAddress, startMapIcon,
        time: DateTime.now(), type: InfoWindowType.position);

    // currentPosition.value = startAddress;
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    currentPosition.notifyListeners();

    return endAddress;
  }

  Future<List<Marker>> addMarker(Address? address, BitmapDescriptor icon,
      {required DateTime time,
      required InfoWindowType type,
      Position? position}) async {
    if (address != null) {
      final marker = Marker(
          markerId: MarkerId(address.id),
          position: address.latLng,
          icon: icon,
          rotation: position?.heading ?? 0,
          anchor: Offset(0.5, 0.5),
          zIndex: 2,
          onTap: () {
            controller.addInfoWindow!(
              CustomWindow(
                info: CityCabInfoWindow(
                  name: "${address.street}, ${address.city}",
                  position: address.latLng,
                  type: type,
                  time: duration,
                ),
              ),
              address.latLng,
            );
          });

      final markerPositionIndex = markers.value
          .indexWhere((marker) => marker.markerId.value == address.id);

      if (markerPositionIndex != -1) {
        markers.value.removeAt(markerPositionIndex);
        markers.value.insert(markerPositionIndex, marker);
      } else {
        markers.value.add(marker);
      }
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      markers.notifyListeners();

      return markers.value;
    } else {
      return markers.value;
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<double> getPositionBetweenKilometers(
      LatLng startLatLng, LatLng endLatLng) async {
    final meters = Geolocator.distanceBetween(startLatLng.latitude,
        startLatLng.longitude, endLatLng.latitude, endLatLng.longitude);
    return meters / 500;
  }

  Future<bool> requestAndCheckPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final request = await Geolocator.requestPermission();
      if (request == LocationPermission.always ||
          request == LocationPermission.whileInUse) {
        return true;
      } else {
        return false;
      }
    } else if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<BitmapDescriptor> getMapIcon(String iconPath) async {
    final Uint8List endMarker = await getBytesFromAsset(iconPath, 65);
    final icon = BitmapDescriptor.fromBytes(endMarker);
    return icon;
  }

  //create a checker function using the getPositionBetweenKilometers() function to check if the driver is within 500 meters of the user
  Future<bool> checkDriverDistance(
      int d, LatLng startLatLng, LatLng endLatLng) async {
    final distance = await getPositionBetweenKilometers(startLatLng, endLatLng);
    if (distance <= d) {
      return true;
    } else {
      return false;
    }
  }

  //create function that returns a boolean if the bus is in between the current location and the destination
  Future<bool> checkBusPassed(
      LatLng startLatLng, LatLng endLatLng, LatLng busLatLng) async {
    final distance1 =
        await getPositionBetweenKilometers(startLatLng, endLatLng);
    final distance2 =
        await getPositionBetweenKilometers(startLatLng, busLatLng);
    final distance3 = await getPositionBetweenKilometers(busLatLng, endLatLng);
    if (distance1 >= distance2 && distance1 >= distance3) {
      return true;
    } else if (distance1 < distance3 && distance1 < distance2) {
      return false;
    } else if (distance1 < distance2 && distance1 > distance3) {
      return true;
    } else {
      return false;
    }
  }

  // create a loadBusMarkers function that call getActiveDrivers from user_repository.dart and call addMarker function only if the bus is within 500 meters of the user
  Future<void> loadBusMarkersWithinDistance(
      LatLng startLatLng, LatLng endLatLng) async {
    final drivers = await UserRepository.instance.getActiveDrivers();
    print(endLatLng);
    for (var i = 0; i < drivers.length; i++) {
      final driver = drivers[i];
      final icon = await getMapIcon(getDriverMapIcon);
      final isWithinDistance = await checkDriverDistance(2, startLatLng,
          LatLng(driver.latlng!.latitude, driver.latlng!.longitude));
      final isBusPassed = await checkBusPassed(startLatLng, endLatLng,
          LatLng(driver.latlng!.latitude, driver.latlng!.longitude));
      print(isBusPassed);
      if (isWithinDistance) {
        await addMarker(
          Address(
            id: driver.uid,
            street: driver.vehicleType,
            city: driver.licensePlate,
            state: driver.vehicleType,
            country: driver.vehicleColor,
            latLng: driver.latlng!,
            polylines: [],
            postcode: driver.licensePlate,
          ),
          icon,
          time: DateTime.now(),
          type: isBusPassed ? InfoWindowType.destination : InfoWindowType.bus,
        );
      }
    }
  }

  //function that computes the distance from the current position of the user to Latlng of each address in my_address.dart constant and returns the first 3 nearest
  Future<List<Address>> getNearestAddressesesList(LatLng startLatLng) async {
    final List<Address> nearestAddresses = [];
    var nearestId = 0;
    var nearestDistance = 999.0;
    for (var i = 0; i < myAddresses.length; i++) {
      final address = myAddresses[i];
      final distance = await getPositionBetweenKilometers(startLatLng,
          LatLng(address.latLng.latitude, address.latLng.longitude));
      // final isWithinDistance = await checkDriverDistance(4, startLatLng,
      //     LatLng(address.latLng.latitude, address.latLng.longitude));
      // if (isWithinDistance && nearestAddresses.length < 3) {
      //   nearestAddresses.add(address);
      // }
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestId = i;
      }
    }
    nearestAddresses.add(myAddresses[nearestId - 1]);
    nearestAddresses.add(myAddresses[nearestId]);
    nearestAddresses.add(myAddresses[nearestId + 1]);
    // print(nearestAddresses.length);
    return nearestAddresses;
  }

  //function that returns the address of the driver (role 1) nearest to the currentposition of the user
  Future<Address?> getNearestDriver(
      LatLng startLatLng, LatLng endLatLng) async {
    final List<Address> addresses = [];

    final buses = await getBusList(startLatLng, endLatLng);

    //iterate through the list of buses, call getAddressFromCoodinate then add it to the list of addresses
    for (var i = 0; i < buses.length; i++) {
      final bus = buses[i];
      final address = await getAddressFromCoodinate(
          LatLng(bus.latlng!.latitude, bus.latlng!.longitude));
      addresses.add(address);
    }

    if (addresses.isNotEmpty) {
      addresses.sort((a, b) => a.postcode.compareTo(b.postcode));
      return addresses.first;
    } else {
      return null;
    }
  }

  //create a function that accepts startLatLng and endLatLng and returns a list of addresses
  Future<List<User>> getBusList(LatLng startLatLng, LatLng endLatLng) async {
    final drivers = await UserRepository.instance.getActiveDrivers();
    final List<User> buses = [];
    for (var i = 0; i < drivers.length; i++) {
      final driver = drivers[i];
      final isWithinDistance = await checkDriverDistance(2, startLatLng,
          LatLng(driver.latlng!.latitude, driver.latlng!.longitude));
      final isBusPassed = await checkBusPassed(startLatLng, endLatLng,
          LatLng(driver.latlng!.latitude, driver.latlng!.longitude));
      if (isWithinDistance && !isBusPassed) {
        final address = await getAddressFromCoodinate(
            LatLng(driver.latlng!.latitude, driver.latlng!.longitude));
        buses.add(driver);
      }
    }

    return buses;
  }
}
