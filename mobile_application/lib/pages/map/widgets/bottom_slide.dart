import 'package:mobile_application/models/user.dart';
import 'package:mobile_application/pages/map/widgets/at_destination.dart';
import 'package:mobile_application/pages/map/widgets/confirm_ride.dart';
import 'package:mobile_application/pages/map/widgets/in_motion.dart';
import 'package:mobile_application/pages/map/widgets/select_a_bus.dart';
import 'package:mobile_application/pages/map/widgets/take_a_ride.dart';
import 'package:mobile_application/pages/map/widgets/ride_bus_details.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/constant/my_address.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../map_state.dart';

class BottomSlider extends StatefulWidget {
  const BottomSlider({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomSlider> createState() => _BottomSliderState();
}

class _BottomSliderState extends State<BottomSlider> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      padding: const EdgeInsets.only(
          bottom: ComTheme.elementSpacing, top: ComTheme.elementSpacing),
      height: _getSliderHeight(state, size),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: ComTheme.cityWhite,
        boxShadow: [
          BoxShadow(
            color: ComTheme.cityBlack.withOpacity(.1),
            spreadRadius: 6,
            blurRadius: 6,
          )
        ],
      ),
      child: PageView(
        onPageChanged: state.onPageChanged,
        controller: state.pageController,
        // physics: NeverScrollableScrollPhysics(),
        physics: BouncingScrollPhysics(),
        children: [
          TakeARide(),
          ConfirmLocation(),
          // SelectRide(),
          // ConfirmRide(),
          // DriverOnTheWay(),
          SelectBus(),
          RideBus(),
          InMotion(),
          ArrivedAtDestination(),
        ],
      ),
    );
  }

  double _getSliderHeight(MapState state, Size size) {
    var checkSearching = state.rideState == RideState.searchingAddress;

    if (checkSearching) {
      if (state.endAddress != null) {
        return size.height * 0.18;
      } else {
        return size.height;
      }
    } else {
      if (state.userRepo.currentUserRole == Roles.driver) {
        return size.height * 0.15;
      }
      return size.height * 0.4;
    }
  }
}

class ConfirmLocation extends StatelessWidget {
  const ConfirmLocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    var checkSearchingEndLocation =
        state.rideState == RideState.searchingAddress &&
            state.endAddress != null;

    return GestureDetector(
      onTap: () {
        state.closeSearching();
      },
      child: Container(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Wrap(
            runAlignment: WrapAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    state.endAddress != null
                        ? SizedBox.shrink()
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Builder(builder: (context) {
                              // if (state.searchedAddress.isEmpty) {
                              //   return Center(
                              //     child: Text('No Address Found'),
                              //   );
                              // }
                              return Scrollbar(
                                  child: ListView.builder(
                                shrinkWrap: true,
                                // itemCount: state.searchedAddress.length,
                                itemCount: myAddresses.length,
                                itemBuilder: (context, index) {
                                  // final address = state.searchedAddress[index];
                                  final address = myAddresses[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.all(1),
                                    horizontalTitleGap: 0,
                                    trailing: Icon(Icons.north_west, size: 16),
                                    title: Text('${address.title}'),
                                    subtitle: Text(
                                        '${address.street}, ${address.city}, ${address.country}'),
                                    leading: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.place_outlined,
                                            color: ComTheme.cityPurple,
                                            size: 18),
                                      ],
                                    ),
                                    onTap: () {
                                      state.onTapAddressList(address);
                                    },
                                  );
                                },
                              ));
                            }),
                          ),
                    // const SizedBox(height: ComTheme.elementSpacing * 3),
                    Padding(
                        padding: const EdgeInsets.all(2),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            CityCabButton(
                              title: 'Request Bus ETA',
                              color: ComTheme.cityPurple,
                              textColor: ComTheme.cityWhite,
                              disableColor: ComTheme.cityLightGrey,
                              buttonState: checkSearchingEndLocation
                                  ? ButtonState.initial
                                  : ButtonState.disabled,
                              onTap: () {
                                state.requestRide();
                              },
                            ),
                            Padding(padding: const EdgeInsets.only(top: 4)),
                            CityCabButton(
                              title: 'Clear',
                              color: ComTheme.cityWhite,
                              textColor: ComTheme.cityPurple,
                              disableColor: ComTheme.cityWhite,
                              buttonState: checkSearchingEndLocation
                                  ? ButtonState.initial
                                  : ButtonState.disabled,
                              onTap: () {
                                state.requestRide();
                              },
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
