import 'package:mobile_application/pages/auth/auth_state.dart';
import 'package:mobile_application/pages/home/home.dart';
import 'package:mobile_application/pages/onboarding/onboarding.dart';
import 'package:mobile_application/main.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/buttons/bus_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthState>();
    return Positioned(
      bottom: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(CityTheme.elementSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CityCabButton(
                  textColor: CityTheme.cityblue,
                  color: CityTheme.cityLightGrey,
                  title: 'Back',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                )),
            CityCabButton(
              textColor: Colors.white,
              color: state.phoneAuthState == PhoneAuthState.loading ||
                      state.phoneAuthState == PhoneAuthState.codeSent
                  ? CityTheme.cityblue
                  : CityTheme.cityblue,
              title: state.phoneAuthState == PhoneAuthState.loading
                  ? 'Loading...'
                  : state.phoneAuthState == PhoneAuthState.codeSent
                      ? 'Verify'
                      : state.pageIndex == 2
                          ? 'Sign Up'
                          : 'Next',
              onTap: state.phoneAuthState == PhoneAuthState.loading
                  ? null
                  : () {
                      if (state.phoneController.text.isNotEmpty &&
                          state.phoneAuthState == PhoneAuthState.initial &&
                          state.pageIndex == 0) {
                        state.phoneNumberVerification(
                            "+63${state.phoneController.text}");
                      } else if (state.phoneAuthState ==
                              PhoneAuthState.codeSent &&
                          state.pageIndex == 1) {
                        state.verifyAndLogin(
                            state.verificationId,
                            state.otpController.text,
                            state.phoneController.text);

                        //go back to homepage to recheck if the user is verified
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                      } else if (state.pageIndex == 2) {
                        state.signUp();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
