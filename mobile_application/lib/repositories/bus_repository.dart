import 'package:mobile_application/models/bus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusRepository {
  BusRepository._();
  static BusRepository? _instance;

  static BusRepository get instance {
    _instance ??= BusRepository._();
    return _instance!;
  }

  final _firestoreBusCollection =
      FirebaseFirestore.instance.collection('buses');

  ValueNotifier<List<Bus>> busNotifier = ValueNotifier<List<Bus>>([]);
  List<Bus> get buses => busNotifier.value;

  Future<Bus?> loadRide(String id) async {
    try {
      final ride = buses.firstWhere((Bus ride) => ride.id == id);
      return ride;
    } catch (_) {
      try {
        final doc = await _firestoreBusCollection.doc(id).get();
        final ride = Bus.fromMap(doc.data() ?? {});
        busNotifier.value.add(ride);
        busNotifier.notifyListeners();

        return ride;
      } on FirebaseException catch (e) {
        print(e.message);
        return null;
      }
    }
  }

  Future<List<Bus>> loadAllBus(String ownerUID) async {
    try {
      final snapshot = _firestoreBusCollection
          .where('owner_uid', isEqualTo: ownerUID)
          .snapshots();
      snapshot.listen((query) {
        _addToBusList(query);
      });
      return buses;
    } on FirebaseException catch (_) {
      print('something occurred');
      return buses;
    }
  }

  void _addToBusList(QuerySnapshot<Map<String, dynamic>> query) {
    Future.wait(query.docs.map((doc) async {
      final ride = Bus.fromMap(doc.data());
      final index = buses.indexWhere((rideX) => rideX.id == ride.id);
      if (index != -1) {
        busNotifier.value.removeAt(index);
        busNotifier.value.insert(index, ride);
      } else {
        busNotifier.value.add(ride);
      }
      busNotifier.notifyListeners();
    }));
  }

  Future<Bus?> boardBus(Bus bus) async {
    try {
      final startAddress = bus.startAddress;
      final endAddress = bus.endAddress;

      // await _firestoreBusCollection.doc(bus.id).set({
      final busDocRef = _firestoreBusCollection.doc(bus.id);
      await busDocRef.set({
        'id': bus.id,
        // 'busList': bus.busList,
        'ownerUID': bus.ownerUID,
        'start_address': {
          'city': startAddress.city,
          'country': startAddress.country,
          'latlng': {
            'lat': startAddress.latLng.latitude,
            'lng': startAddress.latLng.longitude,
          },
          'post_code': startAddress.postcode,
          'state': startAddress.state,
        },
        'end_address': {
          'city': endAddress.city,
          'country': endAddress.country,
          'latlng': {
            'lat': endAddress.latLng.latitude,
            'lng': endAddress.latLng.longitude,
          },
          'post_code': endAddress.postcode,
          'state': endAddress.state,
        },
      });

      // Create the ETA subcollection within the bus document
      final etaCollectionRef = busDocRef.collection('eta');
      // Create the ETA subcollection within the bus document
      // final etaCollectionRef =
      // _firestoreBusCollection.doc(bus.id).collection('eta');

      for (final eta in bus.busList) {
        final etaDocRef =
            etaCollectionRef.doc('eta-${eta.driver['licensePlate']}');
        await etaDocRef.set({
          'driver': eta.driver,
          'eta': eta.eta,
          'timeOfArrival': eta.timeOfArrival,
          'distanceStartBus': eta.distanceStartBus,
          'distanceEndBus': eta.distanceEndBus,
        });
        print('Added ETA document with ID: ${etaDocRef.id}');
      }

      // Add ETA documents to the ETA subcollection
      // for (final eta in bus.busList) {
      //   final etaDocRef = await etaCollectionRef.add({
      //     // await _firestoreBusCollection.add({
      //     'driver': {
      //       'uid': eta.driver['uid'],
      //       'isActive': eta.driver['isActive'],
      //       'firstname': eta.driver['firstname'],
      //       'lastname': eta.driver['lastname'],
      //       'createdAt': eta.driver['createdAt'],
      //       'licensePlate': eta.driver['licensePlate'],
      //       'vehicleType': eta.driver['vehicleType'],
      //       'latlng': eta.driver['latlng'],
      //     },
      //     'eta': eta.eta,
      //     'time_of_arrival': eta.timeOfArrival,
      //   });

      //   print('Added ETA document with ID: ${etaDocRef.id}');
      // }

      // final addedRide = await loadRide(bus.id);
      // final addedRide = await loadRide(busDocRef.doc(bus.id).id);
      final addedRide = await loadRide(busDocRef.id);
      print("done on boarding the ride");
      return addedRide;
    } on FirebaseException catch (_) {
      print('could not board ride');
      return null;
    }
  }
}
