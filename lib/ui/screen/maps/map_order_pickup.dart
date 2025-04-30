import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scan_barcode_app/bloc/test_map2/test_map2_bloc.dart';
import 'package:scan_barcode_app/bloc/test_map2/test_map2_event.dart';
import 'package:scan_barcode_app/bloc/test_map2/test_map2_state.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class MapOrderPickUpScreen extends StatefulWidget {
  @override
  _MapOrderPickUpScreenState createState() => _MapOrderPickUpScreenState();
}

class _MapOrderPickUpScreenState extends State<MapOrderPickUpScreen> {
  late GoogleMapController mapController;
  final searchController = TextEditingController();
  LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);
  late LatLng _selectedPosition = _initialPosition;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _selectedPosition = _initialPosition;
      _loading = false;
      context.read<MapBloc2>().add(UpdateSelectedPosition(
          _initialPosition.latitude,
          _initialPosition.longitude,
          searchController.text));
    });
  }

  void searchLocation(String query) {
    if (query.isNotEmpty) {
      context.read<MapBloc2>().add(SearchLocation(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onBackground,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        surfaceTintColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.background,
        title: TextApp(
          text: "Chọn vị trí",
          fontsize: 20.sp,
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextFormField(
                      onChange: searchLocation,
                      controller: searchController,
                      suffixIcon: const Icon(Icons.search),
                      hintText: '',
                    ),
                  ),
                ),
                Expanded(
                  child: BlocListener<MapBloc2, MapState2>(
                    listener: (context, state) async {
                      if (state is PlaceSelected) {
                        searchController.text = state.description;

                        // Move the camera to the selected location
                        await mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(state.latitude, state.longitude),
                              zoom: 14.0,
                            ),
                          ),
                        );
                        context.read<MapBloc2>().add(FetchLocationDetails(
                            state.latitude, state.longitude));
                      }
                    },
                    child: BlocBuilder<MapBloc2, MapState2>(
                      builder: (context, state) {
                        List<Marker> markers = [
                          Marker(
                            markerId: const MarkerId('currentLocation'),
                            position: _selectedPosition,
                          ),
                        ];
                        if (state is PlaceSelected) {
                          _selectedPosition =
                              LatLng(state.latitude, state.longitude);
                          markers = [
                            Marker(
                              markerId: const MarkerId('selectedLocation'),
                              position: _selectedPosition,
                            ),
                          ];
                        }
                        return Stack(
                          children: [
                            GoogleMap(
                              onMapCreated: (GoogleMapController controller) {
                                mapController = controller;
                              },
                              initialCameraPosition: CameraPosition(
                                target: _initialPosition,
                                zoom: 14.0,
                              ),
                              markers: markers.toSet(),
                              onTap: (LatLng position) {
                                setState(() {
                                  _selectedPosition = position;
                                });
                                context.read<MapBloc2>().add(
                                    UpdateSelectedPosition(
                                        position.latitude,
                                        position.longitude,
                                        searchController.text));
                              },
                            ),
                            if (state is MapLoading)
                              Center(child: CircularProgressIndicator())
                            else if (state is MapLoadSuccess)
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: EdgeInsets.only(top: 16),
                                  color: Colors.white,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.predictions.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(state.predictions[index]
                                            ['description']),
                                        onTap: () {
                                          context.read<MapBloc2>().add(
                                              SelectPlace(
                                                  state.predictions[index]
                                                      ['place_id']));
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )
                            else if (state is MapLoadFailure)
                              Center(child: Text('Error: ${state.error}')),
                            if (state is LocationDetailsFetched)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                    margin: EdgeInsets.all(16.w),
                                    padding: EdgeInsets.all(8.w),
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextApp(
                                            text: 'Địa chỉ: ${state.address}',
                                            maxLines: 3,
                                            fontsize: 16.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // Navigator.pop(
                                            //     context, state.address);
                                            Navigator.of(context).pop({
                                              'address': state.address,
                                              'longitude':
                                                  _selectedPosition.longitude,
                                              'latitude':
                                                  _selectedPosition.latitude,
                                            });
                                          },
                                          child: Container(
                                            width: 60.w,
                                            height: 25.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.r),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            child: Center(
                                              child: TextApp(
                                                textAlign: TextAlign.center,
                                                text: "Chọn",
                                                fontsize: 14.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
