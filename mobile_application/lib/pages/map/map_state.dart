import 'package:mobile_application/constant/ride_options.dart';
import 'package:mobile_application/models/address.dart';
import 'package:mobile_application/models/rate.dart';
import 'package:mobile_application/models/ride.dart';
import 'package:mobile_application/models/ride_option.dart';
import 'package:mobile_application/models/user.dart';
import 'package:mobile_application/repositories/ride_repository.dart';
import 'package:mobile_application/repositories/user_repository.dart';
import 'package:mobile_application/repositories/bus_repository.dart';
import 'package:mobile_application/models/bus.dart';
import 'package:mobile_application/models/eta.dart';
import 'package:mobile_application/services/code_generator.dart';
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
  driverIsComing,
  inMotion,
  arrived,
  selectBus,
}

class MapState extends ChangeNotifier {
  GoogleMapController? controller;
  final currentPosition = MapService.instance!.currentPosition;
  final userRepo = UserRepository.instance;
  final rideRepo = RideRepository.instance;
  final busRepo = BusRepository.instance;

  final currentAddressController = TextEditingController();
  final startingAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  Address? startAddress;
  Address? endAddress;

  RideOption? selectedOption;

  List<Address> searchedAddress = [];
  List<Address> sliderAddresses = [];
  List<bool> isSelectedOptions = [];

  FocusNode? focusNode;
  RideState _rideState = RideState.initial;

  bool isActive = false;

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
    isSelectedOptions =
        List.generate(rideOptions.length, (index) => index == 0 ? true : false);
    selectedOption = rideOptions[0];
    destinationAddressController.addListener(() {
      if (destinationAddressController.text.isEmpty) {
        searchedAddress.clear();
        notifyListeners();
      }
      endAddress = null;
      notifyListeners();
    });
    getCurrentLocation();
    isActive = userRepo.currentUser?.isActive ?? false;
    notifyListeners();
  }

  Set<Polyline> get polylines {
    return {
      if (endAddress?.polylines != [])
        Polyline(
          polylineId: const PolylineId('overview_polyline'),
          color: CityTheme.cityBlack,
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
        if (address != null) {
          if (userRepo.currentUserRole == Roles.driver) {
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
      final myPosition = await MapService.instance?.getPosition(position);
      startAddress = myPosition;

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
    startAddress = MapService.instance?.currentPosition.value;
    endAddress = endPosition;
    notifyListeners();
  }

  Future<void> loadBusRouteCoordinates(LatLng start, LatLng end) async {
    final endPosition =
        await MapService.instance?.getBusRouteCoordinates(start, end);
    startAddress = MapService.instance?.currentPosition.value;
    endAddress = endPosition;
    notifyListeners();
  }

  Future<void> searchAddress(String query) async {
    if (query.length >= 3) {
      await MapService.instance!.getAddressFromQuery(query);
      searchedAddress = MapService.instance?.searchedAddress
              .where((q) =>
                  query.contains("${q.street}") || query.contains("${q.city}"))
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
    focusNode?.unfocus();
    loadMyPosition(address.latLng);
    if (currentAddressController.text.isNotEmpty &&
        destinationAddressController.text.isEmpty) {
      currentAddressController.text = "${address.street}, ${address.city}";
      MapService.instance?.currentPosition.value = address;
      notifyListeners();
      animateCamera(address.latLng);
    } else if (currentAddressController.text.isNotEmpty &&
        destinationAddressController.text.isNotEmpty) {
      destinationAddressController.text = "${address.street}, ${address.city}";
      notifyListeners();
      loadRouteCoordinates(
          MapService.instance!.currentPosition.value!.latLng, address.latLng);
      animateCamera(address.latLng);
    }
  }

  void getCurrentLocation() async {
    final address = await loadMyPosition(null);
    currentAddressController.text = "${address?.street}, ${address?.city}";
    getNearestAddresses();
    notifyListeners();
  }

  void onTapRideOption(RideOption option, int index) {
    for (var i = 0; i < isSelectedOptions.length; i++) {
      isSelectedOptions[i] = false;
    }
    isSelectedOptions[index] = true;
    selectedOption = option;
    notifyListeners();
  }

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
    animateToPage(pageIndex: 0, state: RideState.selectBus);

    final ownerUID = userRepo.currentUser?.uid;
    if (ownerUID != null && ownerUID != '') {
      final bus = await _initializeBus(ownerUID);
      await busRepo.boardBus(bus);
    }
  }

  void proceedRide() {
    animateToPage(pageIndex: 3, state: RideState.confirmAddress);
  }

  void confirmRide() async {
    animateToPage(pageIndex: 4, state: RideState.confirmAddress);
    final ownerUID = userRepo.currentUser?.uid;
    if (ownerUID != null && ownerUID != '') {
      final ride = _initializeRide(ownerUID);
      await rideRepo?.boardRide(ride);
    }
  }

  Ride _initializeRide(String uid) {
    final id = CodeGenerator.instance!.generateCode('city-id');
    final ride = Ride(
      createdAt: DateTime.now(),
      driverUID: '',
      endAddress: endAddress!,
      id: id,
      ownerUID: uid,
      passengers: [uid],
      rate: Rate(uid: uid, subject: '', body: '', stars: 0),
      rideOption: selectedOption!,
      startAddress: startAddress!,
      status: RideStatus.initial,
    );

    return ride;
  }

  void callDriver() {}

  void cancelRide() {
    animateToPage(pageIndex: 0, state: RideState.initial);
  }

  void closeSearching() {
    animateToPage(pageIndex: 0, state: RideState.initial);
  }

  void loadBusMarkers() {
    MapService.instance?.getCurrentPosition().then((value) {
      MapService.instance?.loadBusMarkersWithinDistance(
          value!.latLng, MapService.instance!.searchedAddress[0].latLng);
      var address = MapService.instance
          ?.getNearestDriver(value!.latLng, endAddress!.latLng)
          .then((address) => animateCamera(address?.latLng ?? value.latLng));
    });
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
    MapService.instance?.getCurrentPosition().then((value) {
      MapService.instance
          ?.loadBusMarkersWithinDistance(value!.latLng, endAddress!.latLng);
      MapService.instance
          ?.getNearestDriver(value!.latLng, endAddress!.latLng)
          .then((address) => {
                loadBusRouteCoordinates(address!.latLng, value!.latLng),
                animateCamera(address?.latLng ?? value.latLng)
              });
    });
    // animateToPage(pageIndex: 0, state: RideState.requestRide);
    selectNearbyBus();
  }

  Future<Bus> _initializeBus(String uid) async {
    final id = CodeGenerator.instance!.generateCode('bus-id');
    final bus = Bus(
      id: id,
      busList: await _initializeEta(startAddress!.latLng, endAddress!.latLng),
      ownerUID: uid,
      startAddress: startAddress!,
      endAddress: endAddress!,
    );
    return bus;
  }

  Future<List<Eta>> _initializeEta(LatLng startLatLng, LatLng endLatLng) async {
    final eta = <Eta>[];
    final buses = await MapService.instance!.getBusList(startLatLng, endLatLng);
    print("initializing eta");
    for (var bus in buses) {
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
        },
        eta: 0,
        timeOfArrival: DateTime.now(),
      );
      eta.add(etaItem);
    }
    return eta;
  }

  void onTapMyAddresses(Address address) {
    destinationAddressController.text = "${address.street}, ${address.city}";
    notifyListeners();
    loadRouteCoordinates(
        MapService.instance!.currentPosition.value!.latLng, address.latLng);
    animateCamera(address.latLng);
    searchLocation();
  }

  void changeActivePresence() async {
    isActive = !isActive;
    notifyListeners();
    await userRepo.updateOnlinePresence(userRepo.currentUser?.uid, isActive);
  }
}
