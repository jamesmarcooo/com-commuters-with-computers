//create an onboarding page with 1 image at the top and two buttons at the bottom; the first button should be a commuter button and the second should be a driver button

import 'package:mobile_application/pages/home/home.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:mobile_application/ui/theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  //create a function for navigator push to home page
  void _navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
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
                  ElevatedButton(
                    onPressed: () {
                      _navigateToHomePage(context);
                    },
                    child: const Text('Commuter'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToHomePage(context);
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
            color: CityTheme.cityOrange,
            height: 1,
          ),
    );
  }
}
