import 'package:mobile_application/models/address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const List<Address> myAddresses = [
  Address(
    id: '01',
    title: 'Home',
    city: 'Port Harcourt',
    country: 'Nigeria',
    latLng: LatLng(4.807200, 7.021780),
    polylines: [],
    postcode: '',
    state: 'Rivers',
    street: 'Trans - Amadi',
  ),
  Address(
    id: '02',
    title: 'Office',
    city: 'Port Harcourt',
    country: 'Nigeria',
    latLng: LatLng(4.757670, 7.033320),
    polylines: [],
    postcode: '540001',
    state: 'Rivers',
    street: 'NEW GRA',
  ),
];
