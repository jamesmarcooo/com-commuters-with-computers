import 'package:mobile_application/models/eta.dart';
import 'package:mobile_application/models/address.dart';

class Bus {
  final String id;
  final List<Eta> busList;
  final String ownerUID;
  final Address startAddress;
  final Address endAddress;
  final int eta;
  final DateTime timeOfArrival;

  const Bus(
      {required this.id,
      required this.busList,
      required this.ownerUID,
      required this.startAddress,
      required this.endAddress,
      required this.eta,
      required this.timeOfArrival});

  factory Bus.fromMap(Map<String, dynamic> data) {
    return Bus(
      id: data['id'] ?? '',
      busList: data['busList'] ?? [],
      ownerUID: data['ownerUID'] ?? '',
      startAddress: Address.fromMap(data['start_address'] ?? {}),
      endAddress: Address.fromMap(data['end_address'] ?? {}),
      eta: data['eta'],
      timeOfArrival: DateTime.fromMillisecondsSinceEpoch(
          data['timeOfArrival'].millisecondsSinceEpoch),
    );
  }
}
