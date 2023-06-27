import 'package:mobile_application/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_application/pages/map/map_state.dart';

class UserRepository {
  UserRepository._();
  static UserRepository? _instance;

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._();
    }
    return _instance!;
  }

  Roles? get currentUserRole => currentUser?.role;

  ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);

  User? get currentUser {
    return userNotifier.value;
  }

  Future<User?> setUpAccount(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'email': user.email,
      'firstname': user.firstname,
      'lastname': user.lastname,
      'role': user.role.index,
      'is_verified': user.isVerified,
      'license_plate': user.licensePlate,
      'vehicle_type': user.vehicleType,
      'vehicle_color': user.vehicleColor,
      'vehicle_manufacturer': user.vehicleManufacturer,
      'is_active': user.isActive,
      'latlng': {
        'lat': user.latlng?.latitude,
        'lng': user.latlng?.longitude,
      },
      'busId': '',
    });
    userNotifier.value = await UserRepository.instance.getUser(user.uid);
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    userNotifier.notifyListeners();
    return userNotifier.value;
  }

  Future<User?> getUser(String? uid) async {
    userNotifier.value = null;
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userSnapshot.exists) {
      return null;
    } else {
      Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
      userNotifier.value = User.fromMap(data);
    }

    userNotifier.notifyListeners();
    return userNotifier.value;
  }

  Future<void> signInCurrentUser() async {
    if (UserRepository.instance.currentUser == null) {
      auth.User? authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        print("no current user");
        try {
          authUser = await auth.FirebaseAuth.instance.authStateChanges().first;
        } catch (_) {}
      }
      if (authUser == null) {
        print("no state change user");
      } else {
        await UserRepository.instance.getUser(authUser.uid);
      }
    }
  }

  Future<User?> updateDriverLocation(String? uid, LatLng position) async {
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'latlng': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
      });
      print('updating driver location in firebase');
      return userNotifier.value;
    }
  }

  Future<User?> updateOnlinePresence(String? uid, bool isActive) async {
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'is_active': isActive});
      return userNotifier.value;
    }
    return null;
  }

  //function that updates isSouthBound to true or false
  Future<User?> updateIsSouthBound(String? uid) async {
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'isSouthBound': true, 'isNorthBound': false});
      return userNotifier.value;
    }
    return null;
  }

  Future<User?> updateIsNorthBound(String? uid) async {
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'isNorthBound': true, 'isSouthBound': false});
      return userNotifier.value;
    }
    return null;
  }

  //update the busId in the current user
  Future<User?> updateBusId(String? uid, String? busId) async {
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'busId': busId});
      return userNotifier.value;
    }
    return null;
  }

  //returns the busId in the current user
  Future<String?> getBusId(String? uid) async {
    if (uid != null) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userSnapshot.exists) {
        return null;
      } else {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        return data['busId'];
      }
    }
    return null;
  }

  //returns a list of users with role 1 (driver) and is_active = true (online) and is_verified = true (verified) and not equal to current user id (uid)
  Future<List<User>> getActiveDrivers(
      bool toSouthBound, bool toNorthBound) async {
    List<User> drivers = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 1)
        .where('is_active', isEqualTo: true)
        .where('is_verified', isEqualTo: true)
        .where('isSouthBound', isEqualTo: toSouthBound)
        .where('isNorthBound', isEqualTo: toNorthBound)
        .get();
    querySnapshot.docs.forEach((element) {
      Map<String, dynamic> data = element.data() as Map<String, dynamic>;
      User user = User.fromMap(data);
      if (user.uid != currentUser?.uid) {
        drivers.add(user);
      }
    });
    return drivers;
  }
}
