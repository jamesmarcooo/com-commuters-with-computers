import 'package:mobile_application/pages/auth/auth_state.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:mobile_application/ui/widget/textfields/bus_textfield.dart';
import 'package:flutter/cupertino.dart';
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
            ).paddingBottom(ComTheme.elementSpacing / 2),
            Text(
              'Fill the details below...',
              style: Theme.of(context).textTheme.bodyText1,
            ).paddingBottom(ComTheme.elementSpacing),
            Row(
              children: [
                Expanded(
                  child: CityTextField(
                    label: 'First Name',
                    controller: state.firstNameController,
                  ),
                ),
                SizedBox(width: ComTheme.elementSpacing),
                Expanded(
                  child: CityTextField(
                    label: 'Last Name',
                    controller: state.lastNameController,
                  ),
                ),
              ],
            ).paddingBottom(ComTheme.elementSpacing),
            CityTextField(
              label: 'Email',
              controller: state.emailController,
            ).paddingBottom(ComTheme.elementSpacing),
            Row(
              children: [
                CupertinoSwitch(
                  value: state.isRoleDriver,
                  onChanged: (v) {
                    state.changeRoleState = v == true ? 1 : 0;
                  },
                ),
                SizedBox(width: ComTheme.elementSpacing * 0.5),
                Text(
                  'I\'m a Driver',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ).paddingBottom(ComTheme.elementSpacing),
            Builder(builder: (context) {
              if (state.isRoleDriver == false) return const SizedBox.shrink();
              return Column(
                children: [
                  CityTextField(
                    label: 'Vehicle Type',
                    controller: state.vehicleTypeController,
                  ).paddingBottom(ComTheme.elementSpacing),
                  CityTextField(
                    label: 'Vehicle Manufacturer',
                    controller: state.vehicleManufacturersController,
                  ).paddingBottom(ComTheme.elementSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: CityTextField(
                          label: 'Vehicle Color',
                          controller: state.vehicleColorController,
                        ),
                      ),
                      SizedBox(width: ComTheme.elementSpacing),
                      Expanded(
                        child: CityTextField(
                          label: 'License Plate',
                          controller: state.licensePlateController,
                        ),
                      ),
                    ],
                  ).paddingBottom(ComTheme.elementSpacing),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
