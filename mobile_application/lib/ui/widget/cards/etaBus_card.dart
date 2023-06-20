import 'package:mobile_application/models/eta.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class EtaBusCard extends StatelessWidget {
  final Eta? etaBus;

  final void Function()? onTap;
  const EtaBusCard({
    Key? key,
    this.etaBus,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(0),

      leading: Icon(
          etaBus?.driver['licensePlate'].toLowerCase() ==
                  'Quezon Avenue Station'
              ? Icons.directions_bus_filled_rounded
              : Icons.directions_bus_outlined,
          size: 40,
          color: ComTheme.cityPurple),
      title: Text(
        '${etaBus?.driver['licensePlate']} | EDSA Bus Carousel',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[800],
        ),
      ),
      // subtitle: Text(
      //   '${address?.street}, ${address?.city} , ${address?.country} ',
      subtitle: Text(
        "⏱  ${etaBus?.etaStartBus} min     ⟟  ${double.parse((etaBus?.distanceStartBus)!.toStringAsFixed(2))} km",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_sharp,
        size: 15,
        color: Colors.grey[600],
      ),
    );
  }
}
