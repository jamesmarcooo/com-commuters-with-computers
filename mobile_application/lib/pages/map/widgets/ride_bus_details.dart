import 'package:mobile_application/pages/map/map_state.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/ui/widget/titles/bottom_slider_title.dart';
import 'package:mobile_application/utils/images_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_application/repositories/bus_repository.dart';
import 'package:mobile_application/models/eta.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RideBus extends StatelessWidget {
  const RideBus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();

    return StreamBuilder<QuerySnapshot>(
        stream:
            BusRepository.instance.getEtaBusStream(state.requestedBusId ?? ''),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError ||
              (!snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.waiting)) {
            // return const Text(
            // 'Something went wrong in etaBusListStream in select a bus slider');
            print('1');
            print(snapshot.connectionState == ConnectionState.waiting);
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.active) {
            final List<Eta> busList =
                snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Eta.fromMap(data);
            }).toList();

            if (busList.isEmpty || busList[0].etaStartBus == null) {
              print('2');
              return const Center(child: CircularProgressIndicator());
            }

            //checker if that iterates the busList and returns the index that is the same as the selectedOption
            int index = busList.indexWhere((element) =>
                element.driver['licensePlate'] ==
                state.selectedOption?.driver['licensePlate']);

            print('ETAAAA ${busList[index].timeOfArrival.toString()}');

            var timeOfArrival = DateFormat('hh:mm a').format(busList[index]
                .timeOfArrival
                .add(Duration(
                    minutes: busList[index].etaStartBus?.toInt() ?? 0)));

            // if (busList[0].distanceStartBus < 0.02) {
            //   state.selectNearbyBus();
            // }

            return Wrap(
              runAlignment: WrapAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: BottomSliderTitle(title: 'BUS DETAILS'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: ComTheme.cityPurple.withOpacity(.08),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '⏱',
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Will arrive in ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: ComTheme.cityPurple,
                                            ),
                                          ),
                                          Text(
                                            '${double.parse((busList[index].etaStartBus)!.toStringAsFixed(1))} mins',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: ComTheme.cityPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timelapse_rounded,
                                            color: Colors.grey[600],
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeOfArrival,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: ComTheme.cityPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 4),
                                      Row(
                                        children: [
                                          Text(
                                            ' ⟟ ',
                                            style: TextStyle(
                                              height: 0,
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Distance is ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: ComTheme.cityPurple,
                                            ),
                                          ),
                                          Text(
                                            '${double.parse((busList[index].distanceStartBus).toStringAsFixed(2))} km',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: ComTheme.cityPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child:
                                      Image.asset(ImagesAsset.bus, height: 60),
                                ),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        // '${state.selectedOption!.driver['licensePlate']}',
                                        'EDSA Carousel Bus',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${state.selectedOption!.driver['licensePlate']}',
                                        // '\₦${state.selectedOption?.price}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey[900],
                                        ),
                                      ),
                                    ])
                                // const SizedBox(height: 8),
                              ])
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                              CupertinoIcons.smallcircle_fill_circle_fill,
                              color: ComTheme.cityPurple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              // '${state.startAddress?.street}, ${state.startAddress?.city}, ${state.startAddress?.state}, ${state.startAddress?.country}',
                              state.startingAddressController.text,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          // Icon(Icons.edit, color: Colors.grey[600], size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: CityCabButton(
                //     title: 'RIDE BUS',
                //     color: ComTheme.cityPurple,
                //     textColor: ComTheme.cityWhite,
                //     disableColor: ComTheme.cityLightGrey,
                //     buttonState: ButtonState.initial,
                //     onTap: () {
                //       // state.confirmRide();
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: CityCabButton(
                          title: 'BACK',
                          color: ComTheme.cityWhite,
                          textColor: ComTheme.cityBlack,
                          disableColor: ComTheme.cityLightGrey,
                          buttonState: ButtonState.initial,
                          borderColor: Colors.grey[800],
                          onTap: () {
                            // state.cancelRide();
                            state.pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                            // state.selectNearbyBus();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CityCabButton(
                          title: 'RIDE BUS',
                          color: ComTheme.cityPurple,
                          textColor: ComTheme.cityWhite,
                          disableColor: ComTheme.cityLightGrey,
                          // buttonState: ButtonState.initial,
                          buttonState: state.selectedOption!.etaStartBus! < 2
                              ? ButtonState.initial
                              : ButtonState.disabled,
                          onTap: () {
                            // state.callDriver();
                            state.proceedRide();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            //   return Center(child: const CircularProgressIndicator());
            return Text('No bus details available');
          }
        });
  }
}
