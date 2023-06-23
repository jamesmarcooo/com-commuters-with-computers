import 'package:mobile_application/pages/map/map_state.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/titles/bottom_slider_title.dart';
import 'package:mobile_application/utils/images_assets.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:intl/intl.dart';

class ArrivedAtDestination extends StatelessWidget {
  const ArrivedAtDestination({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    var timeOfArrival = DateFormat('hh:mm a')
        .format(state.selectedOption?.timeOfArrival ?? DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BottomSliderTitle(title: 'Arrived At Destination'),
        ),
        const SizedBox(height: 16),
        RideDetailCard(),
        const SizedBox(height: ComTheme.elementSpacing * 0.5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                top: 20,
                bottom: 25,
                child: Container(
                  width: 2.5,
                  color: Colors.grey[400],
                  height: 80,
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.circle_fill,
                          color: ComTheme.cityPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          // height: 40,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // '${state.startAddress?.street}, ${state.startAddress?.city}',
                              state.startingAddressController.text,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ComTheme.elementSpacing),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.placemark_fill,
                          color: ComTheme.cityPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              state.destinationAddressController.text,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: ComTheme.elementSpacing),
          child: CityCabButton(
            title: 'DROP-OFF & RESTART',
            color: ComTheme.cityPurple,
            textColor: ComTheme.cityWhite,
            disableColor: ComTheme.cityLightGrey,
            buttonState: ButtonState.initial,
            onTap: () {
              state.dropOffRestart();
            },
          ),
        ),
      ],
    );
  }
}

class RideDetailCard extends StatelessWidget {
  const RideDetailCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    var timeOfArrival = DateFormat('hh:mm a')
        .format(state.selectedOption?.timeOfArrival ?? DateTime.now());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Drop-off in ',
                            style: TextStyle(
                              fontSize: 14,
                              color: ComTheme.cityPurple,
                            ),
                          ),
                          Text(
                            '${state.selectedOption?.etaEndBus} mins',
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
                            '${double.parse((state.selectedOption?.distanceStartBus)!.toStringAsFixed(2))} km',
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
                  child: Image.asset(ImagesAsset.bus, height: 60),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
    );
  }
}
