import 'package:mobile_application/models/user.dart';

class Eta {
  // final User driver;
  final Map<String, dynamic> driver;
  final int etaStartBus;
  final int etaEndBus;
  final DateTime timeOfArrival;
  final double distanceStartBus;
  final double distanceEndBus;

  const Eta(
      {required this.driver,
      required this.etaStartBus,
      required this.etaEndBus,
      required this.timeOfArrival,
      required this.distanceStartBus,
      required this.distanceEndBus});

  factory Eta.fromMap(Map<String, dynamic> data) {
    return Eta(
      driver: data['driver'] ?? {},
      etaStartBus: data['etaStartBus'],
      etaEndBus: data['etaEndBus'],
      timeOfArrival: DateTime.fromMillisecondsSinceEpoch(
          data['timeOfArrival'].millisecondsSinceEpoch),
      distanceStartBus: data['distanceStartBus'],
      distanceEndBus: data['distanceEndBus'],
    );
  }
}
