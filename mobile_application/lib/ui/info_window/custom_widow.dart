import 'package:mobile_application/models/info_window.dart';
import 'package:mobile_application/ui/theme.dart';
import 'package:flutter/material.dart';

class CustomWindow extends StatelessWidget {
  const CustomWindow({Key? key, required this.info}) : super(key: key);
  final CityCabInfoWindow info;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: ComTheme.cityWhite,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                      color: ComTheme.cityBlack.withOpacity(.4),
                      spreadRadius: 2,
                      blurRadius: 5),
                ],
              ),
              width: double.infinity,
              height: double.infinity,
              child: Container(
                child: Row(
                  children: [
                    if (info.type == InfoWindowType.position ||
                        info.type == InfoWindowType.bus)
                      Container(
                        width: info.licensePlate == null
                            ? MediaQuery.of(context).size.width * 0.06
                            : MediaQuery.of(context).size.width * 0.12,
                        color: ComTheme.cityPurple,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text('${(info.time?.inMinutes ?? 0) % 60}',
                            //     style: Theme.of(context)
                            //         .textTheme
                            //         .subtitle1
                            //         ?.copyWith(color: ComTheme.cityWhite)),
                            Text('${info.licensePlate?.substring(0, 3) ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(color: ComTheme.cityWhite)),
                            Text('${info.licensePlate?.substring(3) ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(color: ComTheme.cityWhite)),
                          ],
                        ),
                      ),
                    Expanded(
                        child: Text(
                      '${info.name}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: ComTheme.cityBlack),
                    ).paddingAll(8)),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: ComTheme.cityBlack),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
