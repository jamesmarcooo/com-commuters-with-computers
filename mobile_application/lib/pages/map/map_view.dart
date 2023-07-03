import 'package:mobile_application/models/address.dart';
import 'package:mobile_application/pages/map/map_state.dart';
import 'package:mobile_application/pages/map/widgets/bottom_slide.dart';
import 'package:mobile_application/pages/map/widgets/search_map_address.dart';
import 'package:mobile_application/services/auth.dart';
import 'package:mobile_application/services/map_services.dart';
import 'package:mobile_application/ui/info_window/custom_info_window.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  const MapView({Key? key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapState>();
    return SizedBox(
      key: key,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ValueListenableBuilder<Address?>(
        valueListenable: state.currentPosition,
        builder: (context, currentPosition, child) {
          if (currentPosition == null) {
            // return Center(child: const CircularProgressIndicator());
            return SplashScreen(
                seconds: 2,
                // navigateAfterSeconds: const HomePage(),
                // navigateAfterSeconds: const OnboardingPage(),
                image: const Image(
                  image: AssetImage('assets/images/com-02.png'),
                ),
                backgroundColor: const Color(0xff5644B2),
                styleTextUnderTheLoader: const TextStyle(),
                photoSize: 140.0,
                loaderColor: const Color(0xff2A2563));
          }

          return Stack(
            children: [
              ValueListenableBuilder<List<Marker>?>(
                  valueListenable: MapService.instance!.markers,
                  builder: (context, markers, child) {
                    return GoogleMap(
                      mapType: MapType.normal,
                      polylines: state.polylines,
                      markers: markers?.toSet() ?? {},
                      initialCameraPosition: CameraPosition(
                        target: currentPosition.latLng,
                        zoom: 15,
                      ),
                      onMapCreated: state.onMapCreated,
                      onTap: state.onTapMap,
                      onCameraMove: state.onCameraMove,
                    );
                  }),
              CustomInfoWindow(
                controller: MapService.instance!.controller,
                height: MediaQuery.of(context).size.width * 0.12,
                width: MediaQuery.of(context).size.width * 0.4,
                offset: 50,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        AuthService.instance?.logOut();
                        MapService.instance?.dispose();
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: BottomSlider(),
              ),
              state.rideState == RideState.searchingAddress ||
                      state.rideState == RideState.initial
                  ? Positioned(
                      top: 10, left: 15, right: 15, child: SearchMapBar())
                  : SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

class MapViewWidget extends StatelessWidget {
  const MapViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = MapState();
    return ChangeNotifierProvider(
      create: (_) => state,
      child: MapView(key: ValueKey('map')),
    );
  }
}
