import 'package:mobile_application/constant/my_address.dart';
import 'package:mobile_application/models/user.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/ui/widget/cards/address_card.dart';
import 'package:mobile_application/ui/widget/cards/etaBus_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_application/models/eta.dart';
import 'package:mobile_application/repositories/bus_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../map_state.dart';

class SelectBus extends StatelessWidget {
  const SelectBus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    final isUserDriver = state.userRepo.currentUser?.isDriverRole ?? false;
    if (state.sliderAddresses.isEmpty) {
      return Center(child: const CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot>(
      stream:
          BusRepository.instance.getEtaBusStream(state.requestedBusId ?? ''),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text(
              'Something went wrong in etaBusListStream in select a bus slider');
        }

        final List<Eta> busList =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          return Eta.fromMap(data);
        }).toList();

        if (snapshot.connectionState == ConnectionState.waiting ||
            busList.isEmpty ||
            busList[0].etaStartBus == null ||
            !snapshot.hasData) {
          return Center(child: const CircularProgressIndicator());
        }

        if (isUserDriver == true) {
          return Padding(
            padding: const EdgeInsets.all(ComTheme.elementSpacing),
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

        print(
            'select bus slider ${busList[0].distanceStartBus} ${busList[0].etaStartBus}}');

        if (busList.isNotEmpty) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: 8, left: 20, right: 16, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 1),
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 0),
                      shrinkWrap: true,
                      itemCount: busList.length > 5 ? 5 : busList.length,
                      itemBuilder: (context, index) {
                        final etaBus = busList[index];
                        if (etaBus.etaStartBus != null) {
                          state.onTapEta = etaBus.etaStartBus!.toInt();
                          return EtaBusCard(
                            etaBus: etaBus,
                            onTap: () {
                              state.onTapEtaBus(etaBus);
                            },
                          );
                        }
                      }),
                ),
              ],
            ),
          );
        } else {
          //   return Center(child: const CircularProgressIndicator());
          return Text('No buses available');
        }
      },
    );

    // return Builder(builder: (context) {
    //   final isUserDriver = state.userRepo.currentUser?.isDriverRole ?? false;
    //   if (state.sliderEtaBuses.isEmpty) {
    //     // return Center(
    //     //   child: Text('Loading...'),
    //     // );
    //     return Center(child: const CircularProgressIndicator());
    //   }
    //   if (isUserDriver == true) {
    //     return Padding(
    //       padding: const EdgeInsets.all(ComTheme.elementSpacing),
    //       child: CityCabButton(
    //         title: state.isActive ? 'Go Offline' : 'Go Online',
    //         textColor: Colors.white,
    //         color: state.isActive ? Colors.green : Colors.red,
    //         onTap: () {
    //           state.changeActivePresence();
    //         },
    //       ),
    //     );
    //   }
    //   return Padding(
    //     // padding: const EdgeInsets.all(16),
    //     padding: const EdgeInsets.only(bottom: 8, left: 20, right: 16, top: 8),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.stretch,
    //       children: [
    //         const SizedBox(height: 1),
    //         Expanded(
    //           child: ListView.builder(
    //               padding: const EdgeInsets.only(top: 0),
    //               shrinkWrap: true,
    //               itemCount: state.sliderEtaBuses.length > 5
    //                   ? 5
    //                   : state.sliderEtaBuses.length,
    //               itemBuilder: (context, index) {
    //                 final etaBus = state.sliderEtaBuses[index];
    //                 return EtaBusCard(
    //                   etaBus: etaBus,
    //                   onTap: () {
    //                     state.onTapEtaBus(etaBus);
    //                   },
    //                 );
    //               }),
    //         ),
    //       ],
    //     ),
    //   );
    // });
  }
}
