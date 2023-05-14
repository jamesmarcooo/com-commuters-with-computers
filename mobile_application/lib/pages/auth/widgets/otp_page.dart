import 'package:mobile_application/pages/auth/auth_state.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../ui/theme.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);
    return Builder(
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight * 0.6),
                Text(
                  'Enter Code',
                  style: Theme.of(context).textTheme.headline5,
                ).paddingBottom(ComAppTheme.elementSpacing),
                Text(
                  'A 6 digit code has been sent to',
                  style: Theme.of(context).textTheme.bodyText1,
                ).paddingBottom(8),
                Text(
                  // '+63 ${state.phoneController.text}',
                  '+1 ${state.phoneController.text}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ).paddingBottom(ComAppTheme.elementSpacing),
                PinFieldAutoFill(
                  controller: state.otpController,
                  decoration: BoxLooseDecoration(
                    textStyle: TextStyle(fontSize: 20, color: Colors.black),
                    strokeColorBuilder: FixedColorBuilder(Colors.grey),
                  ),
                  currentCode: '',
                  onCodeSubmitted: (code) {},
                  onCodeChanged: (code) {
                    if (code!.length == 6) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                  },
                ),
                Spacer(),
                state.phoneAuthState == PhoneAuthState.loading
                    ? Text(
                        'Verifying...',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.w400),
                      ).paddingBottom(8)
                    : SizedBox.shrink(),
                state.phoneAuthState == PhoneAuthState.codeSent
                    ? Row(
                        children: [
                          Text(
                            'Resend code in ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '0:${state.timeOut}',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          )
                        ],
                      ).paddingBottom(8)
                    : SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
