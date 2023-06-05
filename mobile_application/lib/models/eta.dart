import 'package:mobile_application/models/user.dart';

class Eta {
  final User driver;
  final int eta;
  final DateTime timeOfArrival;

  const Eta(
      {required this.driver, required this.eta, required this.timeOfArrival});

  factory Eta.fromMap(Map<String, dynamic> data) {
    return Eta(
      driver: User.fromMap(data['driver']),
      eta: data['eta'],
      timeOfArrival: DateTime.fromMillisecondsSinceEpoch(
          data['time_of_arrival'].millisecondsSinceEpoch),
    );
  }
}
