import 'package:mobile_application/pages/map/map_state.dart';
import 'package:mobile_application/pages/map/widgets/search_map_address.dart';
import 'package:mobile_application/services/map_services.dart';
import 'package:mobile_application/ui/info_window/custom_info_window.dart';
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
      child: Builder(
        builder: (context) {
          if (state.currentPosition?.value == null) {
            // return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Builder(builder: (context) {
                return GoogleMap(
                  mapType: MapType.normal,
                  polylines: state.polylines,
                  markers: MapService.instance?.markers.value ?? {},
                  initialCameraPosition: CameraPosition(
                    target:
                        state.currentPosition?.value?.latLng ?? LatLng(0, 0),
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
              const Positioned(
                  top: 10, left: 15, right: 15, child: SearchMapBar()),
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
      child: const MapView(key: ValueKey('map')),
    );
  }
}
