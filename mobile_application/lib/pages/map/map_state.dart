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
  driverIsComing,
  // inMotion,
  arrived,
  selectBus,
  busDetails,
  inMotion,
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
  Address? currentAddress;
  Address? busSelectedAddress;

  Address? endTempAddress;

  // RideOption? selectedOption;
  String? requestedBusId;
  Eta? selectedOption;

  List<Address> searchedAddress = [];
  List<Address> sliderAddresses = [];
  List<Eta> sliderEtaBuses = [];
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
    // selectedOption = rideOptions[0];
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
      // final myPosition = await MapService.instance?.getPosition(position);
      // startAddress = myPosition;
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
    startAddress = MapService.instance?.currentPosition.value;
    endAddress = endPosition;
    endTempAddress = endPosition;
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
      currentAddressController.text = "${address.title}, ${address.city}";
      MapService.instance?.currentPosition.value = address;
      notifyListeners();
      animateCamera(address.latLng);
    } else if (currentAddressController.text.isNotEmpty &&
        destinationAddressController.text.isNotEmpty) {
      destinationAddressController.text = "${address.title}, ${address.city}";
      notifyListeners();
      loadRouteCoordinates(
          MapService.instance!.currentPosition.value!.latLng, address.latLng);
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
      sliderEtaBuses = await busRepo.boardBus(bus);

      notifyListeners();
    }
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
    });
    // pageController.nextPage(
    //     duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    selectNearbyBus();
    animateToPage(pageIndex: 2, state: RideState.selectBus);
  }

  Future<Bus> _initializeBus(String uid) async {
    final id = CodeGenerator.instance!.generateCode('bus-id');
    //TODO: fix creating a new bus-id document everytime a user views the bus list
    requestedBusId = id;
    final bus = Bus(
      id: id,
      busList: await _initializeEta(startAddress!.latLng, endAddress!.latLng),
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
    final buses = await MapService.instance!.getBusList(startLatLng, endLatLng);
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
        },
        eta: 0,
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
    notifyListeners();
    loadBusRouteCoordinates(
        // address.latLng, MapService.instance!.currentPosition.value!.latLng);
        BusAddress.latLng,
        startAddress!.latLng);
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
    changeRideState = RideState.busDetails;
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
