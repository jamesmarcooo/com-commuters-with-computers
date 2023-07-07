import 'package:mobile_application/pages/map/map_state.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/textfields/bus_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchMapBar extends StatelessWidget {
  const SearchMapBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: ComTheme.cityWhite,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: ComTheme.cityBlack.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.circle, size: 16, color: ComTheme.cityPurple),
                    Container(width: 4, height: 40, color: ComTheme.cityPurple),
                    Icon(Icons.place, color: ComTheme.cityPurple),
                  ],
                ).paddingHorizontal(4),
                Expanded(
                  child: Column(
                    children: [
                      Focus(
                        focusNode: state.focusNode,
                        child: CityTextField(
                          label: 'Starting Point',
                          controller: state.currentAddressController,
                          onChanged: (v) {
                            state.searchAddress(v);
                            state.searchLocation();
                          },
                        ).paddingBottom(12),
                      ),
                      Focus(
                        focusNode: state.focusNode,
                        child: CityTextField(
                          label: 'Destination Station',
                          controller: state.destinationAddressController,
                          onChanged: (v) {
                            state.searchAddress(v);
                            state.searchLocation();
                          },
                        ),
                      ),
                    ],
                  ).paddingRight(12).paddingVertical(12),
                ),
              ],
            ),
          ],
        ),
      ).paddingAll(8),
    );
  }
}
