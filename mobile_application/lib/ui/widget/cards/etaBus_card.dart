import 'package:mobile_application/models/address.dart';
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
              ? Icons.pin_drop
              : Icons.pin_drop_outlined,
          size: 30,
          color: CityTheme.cityblue),
      title: Text(
        '${etaBus?.driver['licensePlate']}',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[800],
        ),
      ),
      // subtitle: Text(
      //   '${address?.street}, ${address?.city} , ${address?.country} ',
      subtitle: Text(
        "ETA: ${etaBus?.eta} minutes",
        style: TextStyle(
          fontSize: 14,
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
