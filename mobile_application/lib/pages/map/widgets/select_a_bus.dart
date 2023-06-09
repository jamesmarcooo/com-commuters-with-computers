import 'package:mobile_application/constant/my_address.dart';
import 'package:mobile_application/models/user.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/ui/widget/cards/address_card.dart';
import 'package:mobile_application/ui/widget/cards/etaBus_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../map_state.dart';

class SelectBus extends StatelessWidget {
  const SelectBus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();

    return Builder(builder: (context) {
      final isUserDriver = state.userRepo.currentUser?.isDriverRole ?? false;

      if (isUserDriver == true) {
        return Padding(
          padding: const EdgeInsets.all(CityTheme.elementSpacing),
          child: CityCabButton(
            title: state.isActive ? 'Go Offline' : 'Go Online',
            textColor: Colors.white,
            color: state.isActive ? Colors.green : Colors.red,
            onTap: () {
              state.changeActivePresence();
            },
          ),
        );
      }
      return Padding(
        // padding: const EdgeInsets.all(16),
        padding: const EdgeInsets.only(bottom: 8, left: 20, right: 16, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 1),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  shrinkWrap: true,
                  itemCount: state.sliderEtaBuses.length > 5
                      ? 5
                      : state.sliderEtaBuses.length,
                  itemBuilder: (context, index) {
                    final etaBus = state.sliderEtaBuses[index];
                    return EtaBusCard(
                      etaBus: etaBus,
                      onTap: () {
                        state.onTapEtaBus(etaBus);
                      },
                    );
                  }),
            ),
            // Column(
            //   children: List.generate(
            //       state.sliderEtaBuses.length > 4
            //           ? 4
            //           : state.sliderEtaBuses.length, (index) {
            //     final etaBus = state.sliderEtaBuses[index];
            //     return EtaBusCard(
            //       etaBus: etaBus,
            //       onTap: () {
            //         state.onTapEtaBus(etaBus);
            //       },
            //     );
            //   }),
            // ),
          ],
        ),
      );
    });
  }
}
