import 'package:mobile_application/constant/my_address.dart';
import 'package:mobile_application/models/user.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/ui/widget/cards/address_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../map_state.dart';

class TakeARide extends StatelessWidget {
  const TakeARide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();

    return Builder(builder: (context) {
      final isUserDriver = state.userRepo.currentUser?.isDriverRole ?? false;
      if (state.sliderAddresses.isEmpty) {
        return Center(child: const CircularProgressIndicator());
      }
      if (isUserDriver == true) {
        return Padding(
            padding: const EdgeInsets.all(ComTheme.elementSpacing),
            child: Column(
              children: [
                // const SizedBox(height: 8),

                // CityCabButton(
                //   title: state.isActive ? 'END RIDE' : 'START RIDE',
                //   textColor: Colors.white,
                //   color: state.isActive ? Colors.green : Colors.red,
                //   onTap: () {
                //     state.changeActivePresence();
                //   },
                // ),
                Padding(padding: const EdgeInsets.only(top: 8)),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: CityCabButton(
                          title: 'South-bound',
                          color: state.isSouthBound
                              ? ComTheme.cityPurple
                              : ComTheme.cityWhite,
                          textColor: state.isSouthBound
                              ? ComTheme.cityWhite
                              : ComTheme.cityPurple,
                          borderColor: state.isSouthBound
                              ? Colors.grey[800]
                              : ComTheme.cityPurple,
                          buttonState: ButtonState.initial,
                          onTap: () {
                            state.setIsSouthBound();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CityCabButton(
                          title: 'North-bound',
                          color: state.isNorthBound
                              ? ComTheme.cityPurple
                              : ComTheme.cityWhite,
                          textColor: state.isNorthBound
                              ? ComTheme.cityWhite
                              : ComTheme.cityPurple,
                          borderColor: state.isNorthBound
                              ? Colors.grey[800]
                              : ComTheme.cityPurple,
                          disableColor: ComTheme.cityLightGrey,
                          // buttonState: ButtonState.initial,
                          buttonState: ButtonState.initial,
                          onTap: () {
                            state.setIsNorthBound();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
      }
      return Padding(
        // padding: const EdgeInsets.all(16),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                state.searchLocation();
              },
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enter Your Starting Station...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    Icon(Icons.search, size: 30),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Column(
              children: List.generate(
                // myAddresses.length,
                // (index) {
                //   final address = myAddresses[index];
                //   return AddressCard(
                //     address: address,
                //     onTap: () {
                //       state.onTapMyAddresses(address);
                //     },
                //   );
                // },

                //call sliderAddresses from map_state.dart
                state.sliderAddresses.length,
                (index) {
                  final address = state.sliderAddresses[index];
                  return AddressCard(
                    address: address,
                    onTap: () {
                      state.onTapMyAddresses(address);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
