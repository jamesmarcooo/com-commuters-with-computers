import 'package:mobile_application/pages/auth/auth_state.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/textfields/cab_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetUpAccount extends StatelessWidget {
  const SetUpAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AuthState>(context);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight * 0.6),
            Text(
              'Set Up Account',
              style: Theme.of(context).textTheme.headline5,
            ).paddingBottom(ComAppTheme.elementSpacing / 2),
            Text(
              'Fill the details below...',
              style: Theme.of(context).textTheme.bodyText1,
            ).paddingBottom(ComAppTheme.elementSpacing),
            Row(
              children: [
                Expanded(
                  child: CityTextField(
                    label: 'First Name',
                    controller: state.firstNameController,
                  ),
                ),
                SizedBox(width: ComAppTheme.elementSpacing),
                Expanded(
                  child: CityTextField(
                    label: 'Last Name',
                    controller: state.lastNameController,
                  ),
                ),
              ],
            ).paddingBottom(ComAppTheme.elementSpacing),
            CityTextField(
              label: 'Email',
              controller: state.emailController,
            ),
          ],
        ),
      ),
    );
  }
}
