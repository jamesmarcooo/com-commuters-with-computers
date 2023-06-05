import 'package:mobile_application/models/eta.dart';
import 'package:mobile_application/models/address.dart';

class Bus {
  final String id;
  final List<Eta> busList;
  final String driverUID;
  final Address startAddress;
  final Address endAddress;

  const Bus(
      {required this.id,
      required this.busList,
      required this.driverUID,
      required this.startAddress,
      required this.endAddress});

  factory Bus.fromMap(Map<String, dynamic> data) {
    return Bus(
      id: data['id'] ?? '',
      busList: List<Eta>.from(data['bus'] ?? []),
      driverUID: data['driver_uid'] ?? '',
      startAddress: Address.fromMap(data['start_address'] ?? {}),
      endAddress: Address.fromMap(data['end_address'] ?? {}),
    );
  }
}
