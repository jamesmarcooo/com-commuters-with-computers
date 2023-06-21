import 'package:mobile_application/models/bus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/models/eta.dart';

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

  ValueNotifier<List<Eta>> EtaNotifier = ValueNotifier<List<Eta>>([]);
  List<Eta> get etaList => EtaNotifier.value;

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

  Future<List<Eta>> boardBus(Bus bus) async {
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
        'eta': bus.eta,
        'timeOfArrival': bus.timeOfArrival,
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
          'etaStartBus': eta.etaStartBus,
          'etaEndBus': eta.etaEndBus,
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
      // return addedRide;
      return await getEtaList(bus.id);
    } on FirebaseException catch (_) {
      print('could not board ride');
      return List<Eta>.empty();
    }
  }

  //function that gets the requested bus
  Future<Bus?> getBus(String id) async {
    try {
      final doc = await _firestoreBusCollection.doc(id).get();
      final ride = Bus.fromMap(doc.data() ?? {});
      return ride;
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  //function that returns list of eta of the requested bus
  Future<List<Eta>> getEtaList(String id) async {
    try {
      final snapshot = await _firestoreBusCollection
          .doc(id)
          .collection('eta')
          .orderBy('distanceStartBus', descending: false)
          .get();
      final etaList = snapshot.docs.map((doc) => Eta.fromMap(doc.data()));
      print("ETA LIST");
      print(etaList.toList());
      return etaList.toList();
    } on FirebaseException catch (_) {
      print('something occurred');
      return etaList;
    }
  }

  //function that returns an intance of the requested eta
  Future<Eta?> getEta(String id, String etaId) async {
    try {
      final doc = await _firestoreBusCollection
          .doc(id)
          .collection('eta')
          .doc(etaId)
          .get();
      final eta = Eta.fromMap(doc.data() ?? {});
      return eta;
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  //function that updates the requested bus
  Future<List<Eta>> updateBus(Bus bus) async {
    try {
      final startAddress = bus.startAddress;
      final endAddress = bus.endAddress;
      print("-----------------${bus.id}");

      // await _firestoreBusCollection.doc(bus.id).set({
      final busDocRef = _firestoreBusCollection.doc(bus.id);
      await busDocRef.update({
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
        'eta': bus.eta,
        'timeOfArrival': bus.timeOfArrival,
      });
      final etaCollectionRef = busDocRef.collection('eta');

      for (final eta in bus.busList) {
        var checkDocRef = await etaCollectionRef
            .doc('eta-${eta.driver['licensePlate']}')
            .get();

        if (checkDocRef.exists) {
          final etaDocRef =
              etaCollectionRef.doc('eta-${eta.driver['licensePlate']}');

          await etaDocRef.update({
            'driver': eta.driver,
            'etaStartBus': eta.etaStartBus,
            'etaEndBus': eta.etaEndBus,
            'timeOfArrival': eta.timeOfArrival,
            'distanceStartBus': eta.distanceStartBus,
            'distanceEndBus': eta.distanceEndBus,
          });
          print(
              'Updated bus ID ${bus.id} and ETA document with ID ${etaDocRef.id}');
        }
      }

      final updatedRide = await loadRide(busDocRef.id);
      print("done on updating the ride");
      // return addedRide;
      return await getEtaList(bus.id);
    } on FirebaseException catch (e) {
      print('could not update ride');
      print(e.message);
      return List<Eta>.empty();
    }
  }
}
