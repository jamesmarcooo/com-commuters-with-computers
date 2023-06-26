import 'package:mobile_application/models/address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const List<Address> myAddresses = [
  Address(
    id: '1',
    title: 'Monumento Bus Stop',
    city: 'Caloocan',
    country: 'Philippines',
    latLng: LatLng(14.6572, 120.9862),
    polylines: [],
    postcode: '',
    state: 'Morning Breeze Subdivision',
    street: 'Asuncion Street',
  ),
  Address(
    id: '2',
    title: 'Bagong Barrio Bus Stop',
    city: 'Caloocan',
    country: 'Philippines',
    latLng: LatLng(14.6574, 120.9981),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Bagong Barrio West',
  ),
  Address(
    id: '3',
    title: 'Balintawak Bus Stop',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6575, 121.0048),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Balintawak',
  ),
  Address(
    id: '4',
    title: 'Kaingin Bus Stop',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6576, 121.0115),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Balintawak',
  ),
  Address(
    id: '5',
    title: 'Roosevelt Bus Stop',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6577, 121.0197),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Bago Bantay',
  ),
  Address(
    id: '6',
    title: 'North Avenue Bus Stop',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6514, 121.0329),
    polylines: [],
    postcode: '',
    state: 'Diliman',
    street: 'North Avenue',
  ),
  Address(
    id: '7',
    title: 'Quezon Avenue Bus Stop',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6416, 121.0393),
    polylines: [],
    postcode: '',
    state: 'Bagong Pag-asa',
    street: 'Quezon Avenue',
  ),
  Address(
    id: '8',
    title: 'Q-Mart Bus Stop',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6290, 121.0467),
    polylines: [],
    postcode: '',
    state: 'Diliman',
    street: 'Quezon City',
  ),
  Address(
    id: '9',
    title: 'Main Avenue Bus Stop',
    city: 'Cubao, Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6143, 121.0537),
    polylines: [],
    postcode: '',
    state: 'North Bound',
    street: 'Epifanio de los Santos Ave',
  ),
  Address(
    id: '10',
    title: 'Santolan Bus Stop',
    city: 'Quezon City',
    country: 'Philippines',
    latLng: LatLng(14.6088, 121.0554),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Quezon City',
  ),
  Address(
    id: '11',
    title: 'Ortigas Bus Stop',
    city: 'Mandaluyong City',
    country: 'Philippines',
    latLng: LatLng(14.5871, 121.0564),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Ortigas Center',
  ),
  Address(
    id: '12',
    title: 'Guadalupe Bus Stop',
    city: 'Mandaluyong City',
    country: 'Philippines',
    latLng: LatLng(14.5812, 121.0536),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Epifanio de los Santos Ave',
  ),
  Address(
    id: '13',
    title: 'Buendia Bus Stop',
    city: 'Makati City',
    country: 'Philippines',
    latLng: LatLng(14.5550, 121.0350),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Service Road',
  ),
  Address(
    id: '14',
    title: 'Ayala Bus Stop',
    city: 'Makati City',
    country: 'Philippines',
    latLng: LatLng(14.5497, 121.0290),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Makati',
  ),
  Address(
    id: '15',
    title: 'Taft Avenue Bus Stop',
    city: 'Pasay City',
    country: 'Philippines',
    latLng: LatLng(14.5376, 120.9997),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Pasay',
  ),
  Address(
    id: '16',
    title: 'Macapagal Ave Bus Stop',
    city: 'Pasay City',
    country: 'Philippines',
    latLng: LatLng(14.5369, 120.9917),
    polylines: [],
    postcode: '',
    state: '',
    street: 'Pacific Dr',
  ),
  Address(
    id: '17',
    title: 'SM MOA Bus Stop',
    city: 'Pasay City',
    country: 'Philippines',
    latLng: LatLng(14.5351, 120.9834),
    polylines: [],
    postcode: '',
    state: '',
    street: 'SM Mall of Asia',
  ),
  Address(
    id: '18',
    title: 'PITX Bus Stop',
    city: 'Parañaque City',
    country: 'Philippines',
    latLng: LatLng(14.5100, 120.9915),
    polylines: [],
    postcode: '',
    state: '',
    street: 'PITX, Tambo',
  ),
];
