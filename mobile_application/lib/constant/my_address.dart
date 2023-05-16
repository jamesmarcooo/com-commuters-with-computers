import 'package:mobile_application/models/address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const List<Address> myAddresses = [
  Address(
    id: '01',
    title: 'Quezon Avenue Station',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6416, 121.0393),
    // latLng: LatLng(4.807200, 7.021780),
    polylines: [],
    postcode: '',
    state: 'Bagong Pag-asa',
    street: 'Quezon Avenue',
  ),
  Address(
    id: '02',
    title: 'North Avenue Station',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6514, 121.0329),
    // latLng: LatLng(4.757670, 7.033320),
    polylines: [],
    postcode: '540001',
    state: 'Diliman',
    street: 'North Avenue',
  ),
];
