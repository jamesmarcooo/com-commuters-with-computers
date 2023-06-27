import 'package:mobile_application/models/address.dart';
import 'package:mobile_application/models/rate.dart';
import 'package:mobile_application/models/user.dart';
import 'package:mobile_application/repositories/user_repository.dart';
import 'package:mobile_application/repositories/bus_repository.dart';
import 'package:mobile_application/models/bus.dart';
import 'package:mobile_application/models/eta.dart';
import 'package:mobile_application/services/code_generator.dart';
import 'package:mobile_application/models/info_window.dart';
import 'package:mobile_application/ui/info_window/custom_info_window.dart';
import 'package:mobile_application/ui/info_window/custom_widow.dart';
import 'package:mobile_application/services/map_services.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RideState {
  initial,
  searchingAddress,
  confirmAddress,
  selectRide,
  requestRide,
  selectBus,
  busDetails,
  inMotion,
  arrived,
}

class MapState extends ChangeNotifier {
  GoogleMapController? controller;
  final currentPosition = MapService.instance!.currentPosition;
  final userRepo = UserRepository.instance;
  final busRepo = BusRepository.instance;

  final currentAddressController = TextEditingController();
  final startingAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final endAddressController = TextEditingController();

  Address? startAddress;
  Address? endAddress;
  Address? currentAddress;
  Address? busSelectedAddress;

  Address? endTempAddress;

  // RideOption? selectedOption;
  String? requestedBusId;
  Eta? selectedOption;

  List<Address> searchedAddress = [];
  List<Address> sliderAddresses = [];
  List<Eta> sliderEtaBuses = [];

  FocusNode? focusNode;
  RideState _rideState = RideState.initial;

  //bus
  bool isActive = false;
  bool isSouthBound = false;
  bool isNorthBound = false;

  //route start-destination
  bool toSouthBound = false;
  bool toNorthBound = false;

  RideState get rideState {
    return _rideState;
  }

  set changeRideState(RideState state) {
    _rideState = state;
    notifyListeners();
  }

  final pageController = PageController();

  int pageIndex = 0;

  MapState() {
    focusNode = FocusNode();
    destinationAddressController.addListener(() {
      if (destinationAddressController.text.isEmpty) {
        searchedAddress.clear();
        notifyListeners();
      }
      endAddress = null;
      notifyListeners();
    });
    getCurrentLocation();
    requestedBusId = userRepo.currentUser?.busId;
    isActive = userRepo.currentUser?.isActive ?? false;
    notifyListeners();
  }

  Set<Polyline> get polylines {
    return {
      if (endAddress?.polylines != [])
        Polyline(
          polylineId: const PolylineId('overview_polyline'),
          color: ComTheme.cityBlack,
          width: 5,
          points: endAddress?.polylines
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList() ??
              [],
        ),
    };
  }

  @override
  void dispose() {
    MapService.instance?.controller.dispose();
    super.dispose();
  }

  Future<void> animateCamera(LatLng latLng) async {
    await controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude), zoom: 16.5),
    ));
  }

  Future<Address?> loadMyPosition(LatLng? position) async {
    if (position == null) {
      final position = await MapService.instance?.getCurrentPosition();
      startAddress = position;

      MapService.instance?.listenToPositionChanges(
          eventFiring: (Address? address) async {
        // print('changing ${address?.latLng}');
        if (address != null) {
          if (userRepo.currentUserRole == Roles.driver) {
            print('updating bus driver location');
            await userRepo.updateDriverLocation(
                UserRepository.instance.currentUser?.uid, address.latLng);
          }
        }

        startAddress = address;
        notifyListeners();
        print('updating address');
      }).listen((event) {});
      animateCamera(startAddress!.latLng);
      notifyListeners();
    } else {
      // final myPosition = await MapService.instance?.getPosition(position);
      // startAddress = myPosition;
      print('currrentPosition.value as startAddress');
      startAddress = currentPosition.value;

      animateCamera(startAddress!.latLng);
      notifyListeners();
    }
    MapService.instance?.markers.notifyListeners();

    notifyListeners();
    return startAddress;
  }

  Future<void> loadRouteCoordinates(LatLng start, LatLng end) async {
    final endPosition =
        await MapService.instance?.getRouteCoordinates(start, end);
    if (rideState == RideState.inMotion) {
      startAddress = MapService.instance?.currentPosition.value;
    }
    endAddress = endPosition;
    endTempAddress = endPosition;
    notifyListeners();
  }

  Future<void> loadBusRouteCoordinates(LatLng start, LatLng end) async {
    final endPosition =
        await MapService.instance?.getBusRouteCoordinates(start, end);
    // startAddress = MapService.instance?.currentPosition.value;
    endAddress = endPosition;
    notifyListeners();
  }

  Future<void> searchAddress(String query) async {
    if (query.length >= 3) {
      await MapService.instance!.getAddressFromQuery(query);
      searchedAddress = MapService.instance?.searchedAddress
              .where((q) =>
                  query.contains("${q.title}") ||
                  query.contains("${q.street}") ||
                  query.contains("${q.city}"))
              .toList() ??
          [];
    }

    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    MapService.instance?.controller.googleMapController = controller;
    animateCamera(currentPosition.value?.latLng ?? LatLng(0, 0));
  }

  void onTapMap(LatLng argument) {
    MapService.instance?.controller.hideInfoWindow!();
  }

  void onCameraMove(CameraPosition position) {
    MapService.instance?.controller.onCameraMove!();
  }

  void onTapAddressList(Address address) {
    print(startingAddressController.text);
    print(currentAddressController.text);
    // focusNode?.unfocus();
    // loadMyPosition(address.latLng);
    if ((currentAddressController.text != startingAddressController.text) &&
        currentAddressController.text.isNotEmpty &&
        destinationAddressController.text.isEmpty) {
      currentAddressController.text = "${address.title}, ${address.city}";
      startingAddressController.text = "${address.title}, ${address.city}";
      MapService.instance?.currentPosition.value = address;
      startAddress = address;
      print('startAddress in start: ${startAddress!.title}');
      notifyListeners();
      animateCamera(address.latLng);
    } else if ((currentAddressController.text.isNotEmpty &&
            destinationAddressController.text.isNotEmpty) ||
        (currentAddressController.text == startingAddressController.text)) {
      destinationAddressController.text = "${address.title}, ${address.city}";

      if (RideState.searchingAddress == rideState) {
        endAddressController.text = "${address.title}, ${address.city}";
      }
      print(destinationAddressController.text);
      print(int.parse(startAddress!.id));
      print(int.parse(address.id));
      print('startAddress in end: ${startAddress!.title}');
      print('destinationAddress in end: ${endAddressController.text}');

      notifyListeners();
      print('ridestate: $rideState');

      //convert startAddress id to integer and get the difference with address id
      if (int.parse(startAddress!.id) - int.parse(address.id) > 0) {
        toSouthBound = false;
        toNorthBound = true;
        print('going north');
        print(int.parse(startAddress!.id) - int.parse(address.id));
      } else if (int.parse(startAddress!.id) - int.parse(address.id) < 0) {
        toSouthBound = true;
        toNorthBound = false;
        print('going south');
        print(int.parse(startAddress!.id) - int.parse(address.id));
      }

      if (rideState == RideState.inMotion) {
        loadRouteCoordinates(
            MapService.instance!.currentPosition.value!.latLng, address.latLng);
      } else {
        if (toSouthBound == false && toNorthBound == true) {
          loadRouteCoordinates(startAddress!.latLngNorth, address.latLngNorth);
        } else if (toSouthBound == true && toNorthBound == false) {
          loadRouteCoordinates(startAddress!.latLngSouth, address.latLngSouth);
        }
      }

      // loadRouteCoordinates(MapService.instance!.currentPosition.value!.latLng, address.latLng);
      animateCamera(
          endTempAddress == address ? startAddress!.latLng : address.latLng);
    }
  }

  void getCurrentLocation() async {
    final address = await loadMyPosition(null);
    currentAddressController.text = "${address?.street}, ${address?.city}";
    getNearestAddresses();
    notifyListeners();
  }

  // void onTapRideOption(RideOption option, int index) {
  //   for (var i = 0; i < isSelectedOptions.length; i++) {
  //     isSelectedOptions[i] = false;
  //   }
  //   isSelectedOptions[index] = true;
  //   selectedOption = option;
  //   notifyListeners();
  // }

  void onPageChanged(int value) {
    pageIndex = value;
    notifyListeners();
  }

  void animateToPage({required int pageIndex, required RideState state}) {
    pageController.jumpToPage(pageIndex);
    changeRideState = state;
  }

  void searchLocation() {
    animateToPage(pageIndex: 1, state: RideState.searchingAddress);
  }

  void selectNearbyBus() async {
    // animateToPage(pageIndex: 7, state: RideState.selectBus);
    final ownerUID = userRepo.currentUser?.uid;
    if (ownerUID != null && ownerUID != '') {
      final bus = await _initializeBus(ownerUID);

      print('bbbbbbbus: ${bus.id}');
      print('requesting bus: ${requestedBusId}');
      if (requestedBusId == '') {
        sliderEtaBuses = await busRepo.boardBus(bus);
        requestedBusId = bus.id;
        await userRepo.updateBusId(ownerUID, bus.id);
      } else {
        sliderEtaBuses = await busRepo.updateBus(bus);
      }

      notifyListeners();
    }

    //check if owerUID has already a bus, then update the bus instead of boarding a new one
  }

  void proceedRide() {
    animateToPage(pageIndex: 4, state: RideState.inMotion);
    onTapAddressList(endTempAddress!);

    MapService.instance?.controller.addInfoWindow!(
      CustomWindow(
        info: CityCabInfoWindow(
          name:
              "${currentPosition.value!.street}, ${currentPosition.value!.city}",
          position: currentPosition.value!.latLng,
          type: InfoWindowType.position,
          time: Duration(),
        ),
      ),
      currentPosition.value!.latLng,
    );
    // animateCamera(currentPosition.value!.latLng);
  }

  // void confirmRide() async {
  //   animateToPage(pageIndex: 4, state: RideState.confirmAddress);
  //   final ownerUID = userRepo.currentUser?.uid;
  //   if (ownerUID != null && ownerUID != '') {
  //     final ride = _initializeRide(ownerUID);
  //     await rideRepo?.boardRide(ride);
  //   }
  // }

  // Ride _initializeRide(String uid) {
  //   final id = CodeGenerator.instance!.generateCode('city-id');
  //   final ride = Ride(
  //     createdAt: DateTime.now(),
  //     driverUID: '',
  //     endAddress: endAddress!,
  //     id: id,
  //     ownerUID: uid,
  //     passengers: [uid],
  //     rate: Rate(uid: uid, subject: '', body: '', stars: 0),
  //     rideOption: selectedOption!,
  //     startAddress: startAddress!,
  //     status: RideStatus.initial,
  //   );

  //   return ride;
  // }

  void callDriver() {}

  void cancelRide() {
    animateToPage(pageIndex: 0, state: RideState.initial);
  }

  void dropOffRestart() {
    animateToPage(pageIndex: 0, state: RideState.initial);
    searchedAddress.clear();
    sliderEtaBuses.clear();
    sliderAddresses.clear();
    getCurrentLocation();
    startAddress = null;
    endAddress = null;
    currentAddress = null;
    busSelectedAddress = null;

    endTempAddress = null;
    destinationAddressController.clear();
    startingAddressController.clear();
    MapService.instance?.controller.hideInfoWindow!();
    notifyListeners();
  }

  void closeSearching() {
    animateToPage(pageIndex: 0, state: RideState.initial);
  }

  void loadBusMarkers() {
    var value = startAddress;
    var valueLatLng;
    if (toNorthBound == true && toSouthBound == false) {
      valueLatLng = value!.latLngNorth;
    } else if (toNorthBound == false && toSouthBound == true) {
      valueLatLng = value!.latLngSouth;
    }
    // MapService.instance?.getCurrentPosition().then((value) {
    MapService.instance?.loadBusMarkersWithinDistance(
        valueLatLng,
        MapService.instance!.searchedAddress[0].latLng,
        toSouthBound,
        toNorthBound);
    var address = MapService.instance
        ?.getNearestDriver(
            value!.latLng, endAddress!.latLng, toSouthBound, toNorthBound)
        .then((address) => animateCamera(address?.latLng ?? value.latLng));
    notifyListeners();
    // });
  }

  //function to get the first 3 nearest address from the current position
  Future<void> getNearestAddresses() async {
    final nearestAddress = await MapService.instance
        ?.getNearestAddressesesList(startAddress!.latLng);
    sliderAddresses = nearestAddress ?? [];
    notifyListeners();
  }

  void requestRide() {
    //call addBusMarkers from map_service.dart
    // MapService.instance?.loadBusMarkers();

    // MapService.instance?.getCurrentPosition().then((value) {
    var value = startAddress;
    MapService.instance?.loadBusMarkersWithinDistance(
        value!.latLng, endAddress!.latLng, toSouthBound, toNorthBound);
    MapService.instance
        ?.getNearestDriver(
            value!.latLng, endAddress!.latLng, toSouthBound, toNorthBound)
        .then((address) => {
              // loadBusRouteCoordinates(address!.latLng, value.latLng),
              // animateCamera(address.latLng),
              // MapService.instance?.controller.addInfoWindow!(
              //   CustomWindow(
              //     info: CityCabInfoWindow(
              //       name: "${address.street}, ${address.city}",
              //       position: address.latLng,
              //       type: InfoWindowType.bus,
              //       time: Duration(),
              //     ),
              //   ),
              //   address.latLng,
              // )
              onTapSliderAddress(address!, value)
            });
    // });
    // pageController.nextPage(
    //     duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    notifyListeners();
    selectNearbyBus();
    animateToPage(pageIndex: 2, state: RideState.selectBus);
  }

  Future<Bus> _initializeBus(String uid) async {
    var id;
    if (requestedBusId == '') {
      id = CodeGenerator.instance!.generateCode('bus-id');
    } else {
      id = requestedBusId;
    }

    var startAddressLatLng;
    var endAddressLatLng;
    if (toNorthBound == true && toSouthBound == false) {
      startAddressLatLng = startAddress!.latLngNorth;
      endAddressLatLng = endAddress!.latLngNorth;
    } else if (toNorthBound == false && toSouthBound == true) {
      startAddressLatLng = startAddress!.latLngSouth;
      endAddressLatLng = endAddress!.latLngSouth;
    }
    //TODO: fix creating a new bus-id document everytime a user views the bus list
    final bus = Bus(
      id: id,
      busList: await _initializeEta(startAddressLatLng, endAddressLatLng),
      ownerUID: uid,
      startAddress: startAddress!,
      endAddress: endAddress!,
      eta: 0,
      timeOfArrival: DateTime.now(),
    );
    //call getEtaList from bus_repository.dart
    // sliderEtaBuses = await busRepo.getEtaList(bus.id);
    return bus;
  }

  Future<List<Eta>> _initializeEta(LatLng startLatLng, LatLng endLatLng) async {
    final eta = <Eta>[];
    final buses = await MapService.instance!
        .getBusList(startLatLng, endLatLng, toSouthBound, toNorthBound);
    print("initializing eta");
    for (var bus in buses) {
      var distanceStartBus = await MapService.instance!
          .getPositionBetweenKilometers(
              startLatLng, LatLng(bus.latlng!.latitude, bus.latlng!.longitude));
      var distanceEndBus = await MapService.instance!
          .getPositionBetweenKilometers(
              LatLng(bus.latlng!.latitude, bus.latlng!.longitude), endLatLng);
      print(
          '${double.parse((distanceStartBus).toStringAsFixed(2))}, ${double.parse((distanceEndBus).toStringAsFixed(2))}');
      // final id = CodeGenerator.instance!.generateCode('eta-id');
      final etaItem = Eta(
        driver: {
          'uid': bus.uid,
          'isActive': bus.isActive,
          'firstname': bus.firstname,
          'lastname': bus.lastname,
          'createdAt': bus.createdAt,
          'licensePlate': bus.licensePlate,
          'vehicleType': bus.vehicleType,
          'latlng': {
            'latitude': bus.latlng!.latitude,
            'longitude': bus.latlng!.longitude,
          },
          'isSouthBound': bus.isSouthBound,
          'isNorthBound': bus.isNorthBound,
        },
        etaStartBus: 0.0,
        etaEndBus: 0.0,
        timeOfArrival: DateTime.now(),
        distanceStartBus: distanceStartBus,
        distanceEndBus: distanceEndBus,
      );
      eta.add(etaItem);
    }
    // sliderEtaBuses = eta;
    return eta;
  }

  void onTapSliderAddress(Address BusAddress, Address CurrentAddress) {
    var startAddressLatLng;
    if (toNorthBound == true && toSouthBound == false) {
      startAddressLatLng = startAddress!.latLngNorth;
    } else if (toNorthBound == false && toSouthBound == true) {
      startAddressLatLng = startAddress!.latLngSouth;
    }
    notifyListeners();
    loadBusRouteCoordinates(
        // address.latLng, MapService.instance!.currentPosition.value!.latLng);
        BusAddress.latLng,
        startAddressLatLng);
    animateCamera(BusAddress.latLng);
    MapService.instance?.controller.addInfoWindow!(
      CustomWindow(
        info: CityCabInfoWindow(
          name: "${BusAddress.street}, ${BusAddress.city}",
          position: BusAddress.latLng,
          type: InfoWindowType.bus,
          time: Duration(),
        ),
      ),
      BusAddress.latLng,
    );
    // searchLocation();
  }

  //craate a function that gets an input of Eta and calls proceedRide()
  void onTapEtaBus(Eta eta) async {
    // destinationAddressController.text = "${address.street}, ${address.city}";
    //call getAddressFromCoodinate() from map_services.dart
    // final currentAddress = await MapService.instance!.currentPosition.value;
    var etaDriverLatLng = LatLng(
        eta.driver['latlng']['latitude'], eta.driver['latlng']['longitude']);
    var etaBusAddress =
        await MapService.instance?.getAddressFromCoodinate(etaDriverLatLng);
    onTapSliderAddress(etaBusAddress!, startAddress!);
    // proceedRide();
    // animateToPage(pageIndex: 7, state: RideState.confirmAddress);

    print(requestedBusId);
    selectedOption = await busRepo.getEta(
        requestedBusId!, 'eta-${eta.driver['licensePlate']}');
    notifyListeners();
    pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    changeRideState = RideState.inMotion;
  }

  void onTapMyAddresses(Address address) {
    // destinationAddressController.text =

    // startingAddressController.text =
    //     "${address.title}, ${address.street}, ${address.city}";
    startingAddressController.text = "${address.title}, ${address.city}";
    currentAddressController.text = "${address.title}, ${address.city}";

    startAddress = address;

    notifyListeners();
    // loadRouteCoordinates(MapService.instance!.currentPosition.value!.latLng, address.latLng);
    animateCamera(address.latLng);
    searchLocation();
  }

  void changeActivePresence() async {
    isActive = !isActive;
    notifyListeners();
    await userRepo.updateOnlinePresence(userRepo.currentUser?.uid, isActive);
  }

  //function that sets isSouthBound to true, and isNorthBound to false
  void setIsSouthBound() async {
    isSouthBound = true;
    isNorthBound = false;
    print(isNorthBound);
    print(isSouthBound);
    await userRepo.updateIsSouthBound(userRepo.currentUser?.uid);
    notifyListeners();
  }

  void setIsNorthBound() async {
    isSouthBound = false;
    isNorthBound = true;
    print(isNorthBound);
    print(isSouthBound);
    await userRepo.updateIsNorthBound(userRepo.currentUser?.uid);
    notifyListeners();
  }
}
