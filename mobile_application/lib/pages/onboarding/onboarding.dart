//create an onboarding page with 1 image at the top and two buttons at the bottom; the first button should be a commuter button and the second should be a driver button

import 'package:mobile_application/pages/home/home.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/pages/map/map_view.dart';
import 'package:mobile_application/pages/auth/auth_page.dart';
import 'package:mobile_application/ui/theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  //create a function for navigator push to home page
  void _navigateToAuthPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthPageWidget(page: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CityTheme.cityWhite,
      child: Stack(
        children: [
          Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/human-onboard-01.png'),
                  const AuthHeader('Welcome!'),
                  //add padding around the buttons
                  const SizedBox(height: 40),
                  ElevatedButton(
                    //add style to the button
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(256, 64),
                      primary: CityTheme.cityblue,
                      onPrimary: CityTheme.cityWhite,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      _navigateToAuthPage(context);
                    },
                    child: const Text('Commuter'),
                  ),
                  //add Elevated for admin with bigger font size
                  Padding(padding: const EdgeInsets.only(top: 16)),
                  ElevatedButton(
                    //add style to the button
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(256, 64),
                      primary: CityTheme.cityLightGrey,
                      onPrimary: CityTheme.cityblue,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      _navigateToAuthPage(context);
                    },
                    child: const Text('Driver'),
                  ),
                ]),
          )
        ],
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String title;
  const AuthHeader(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline1?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 72,
            color: CityTheme.cityblue,
            height: 1,
          ),
    );
  }
}
