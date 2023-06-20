import 'package:mobile_application/constant/ride_options.dart';
import 'package:mobile_application/pages/map/map_state.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/ui/widget/cards/ride_card.dart';
import 'package:mobile_application/ui/widget/titles/bottom_slider_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectRide extends StatelessWidget {
  const SelectRide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<MapState>(context);
    return Wrap(
      runAlignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: BottomSliderTitle(title: 'SELECT RIDE OPTION'),
            ),
            const SizedBox(height: 16),
            Container(
              height: 140,
              child: ListView.builder(
                itemCount: rideOptions.length,
                padding: const EdgeInsets.only(left: 16, right: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final option = rideOptions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: RideOptionCard(
                      isSelected: state.isSelectedOptions[index],
                      onTap: (option) {
                        // state.onTapRideOption(option, index);
                      },
                      option: option,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CityCabButton(
            // title: 'PROCEED WITH ${state.selectedOption?.title.toUpperCase()}',
            title: 'PROCEED WITH',
            color: CityTheme.cityblue,
            textColor: CityTheme.cityWhite,
            disableColor: CityTheme.cityLightGrey,
            buttonState: ButtonState.initial,
            onTap: () {
              state.proceedRide();
            },
          ),
        ),
      ],
    );
  }
}
