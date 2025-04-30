import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/bloc/order_pickup/tracking_order_pickup/tracking_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/choose_branch_return.dart/choose_branch_return_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/ui/screen/shipper/update_status_order.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapShipperTest extends StatefulWidget {
  final DetailsOrderPickUpModel detailsOrderPickUp;
  double longitude;
  double latitude;
  String idKeyDestination;
  MapShipperTest(
      {required this.detailsOrderPickUp,
      required this.longitude,
      required this.latitude,
      required this.idKeyDestination,
      super.key});
  @override
  _MapShipperTestState createState() => _MapShipperTestState();
}

class _MapShipperTestState extends State<MapShipperTest> {
  GoogleMapController? mapController;
  LatLng? _initialPosition;
  double? _destinationLatitude;
  double? _destinationLongitude;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapReady = false;
  late BitmapDescriptor _customMarker;
  bool _isDialogShown = false;

  // Throttling variables
  Timer? _locationUpdateTimer;
  Timer? _routeUpdateTimer;
  DateTime? _lastRouteUpdate;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Cache for route polyline
  String? _lastPolyline;
  LatLng? _lastRouteStart;
  LatLng? _lastRouteEnd;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _setCustomMarker();
    _loadSavedDestination();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _routeUpdateTimer?.cancel();
    _positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadSavedDestination() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _destinationLatitude =
          prefs.getDouble('destinationLatitude${widget.idKeyDestination}') ??
              widget.latitude;
      _destinationLongitude =
          prefs.getDouble('destinationLongitude${widget.idKeyDestination}') ??
              widget.longitude;
    });
  }

  Future<void> _saveDestination(double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
        'destinationLatitude${widget.idKeyDestination}', latitude);
    await prefs.setDouble(
        'destinationLongitude${widget.idKeyDestination}', longitude);
    log("SAVE OK");
    log("destinationLatitude");
    log(prefs
        .getDouble('destinationLatitude${widget.idKeyDestination}')
        .toString());
    log("destinationLongitude");
    log(prefs
        .getDouble('destinationLongitude${widget.idKeyDestination}')
        .toString());
  }

  Future<void> _initializeMap() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          _isMapReady = true;
          _updateMarkers();
          _drawRoute();
        });
      }

      // Set up position stream with throttling
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update only when moved 10 meters
        ),
      ).listen(_handlePositionUpdate);
    } catch (e) {
      print("Error initializing map: $e");
    }
  }

  void _handlePositionUpdate(Position position) {
    if (!mounted) return;

    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          _updateMarkers();
          _updateShipperPosition();
          _checkArrival();
          _updateRouteIfNeeded();
        });
      }
    });
  }

  void _updateShipperPosition() {
    if (_initialPosition == null) return;

    context.read<TrackingOrderPickupBloc>().add(
          HanldeTrackingOrderPickup(
            shipperLongitude: _initialPosition!.longitude,
            shipperLatitude: _initialPosition!.latitude,
            locationAddress: widget.detailsOrderPickUp.data.orderPickupAddress!,
          ),
        );
  }

  void _updateRouteIfNeeded() {
    if (_initialPosition == null ||
        _destinationLatitude == null ||
        _destinationLongitude == null) return;

    final now = DateTime.now();
    if (_lastRouteUpdate != null &&
        now.difference(_lastRouteUpdate!) < Duration(seconds: 30)) {
      return; // Throttle route updates to every 30 seconds
    }

    final currentStart = _initialPosition;
    final currentEnd = LatLng(_destinationLatitude!, _destinationLongitude!);

    // Check if route needs to be updated based on significant position change
    if (_lastRouteStart != null && _lastRouteEnd != null) {
      final startDistance = Geolocator.distanceBetween(
        currentStart!.latitude,
        currentStart.longitude,
        _lastRouteStart!.latitude,
        _lastRouteStart!.longitude,
      );

      if (startDistance < 50) {
        // Only update if moved more than 50 meters
        return;
      }
    }

    _drawRoute();
    _lastRouteUpdate = now;
    _lastRouteStart = currentStart;
    _lastRouteEnd = currentEnd;
  }

  Future<void> _setCustomMarker() async {
    _customMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(4, 4)),
      'assets/images/shipper_kango_2_70x70.png',
    );
  }

  void _updateMarkers() {
    if (mounted &&
        _initialPosition != null &&
        _destinationLatitude != null &&
        _destinationLongitude != null) {
      setState(() {
        _markers = {
          Marker(
              markerId: MarkerId('currentLocation'),
              position: _initialPosition!,
              icon: _customMarker),
          Marker(
            markerId: MarkerId('destinationLocation'),
            position: LatLng(_destinationLatitude!, _destinationLongitude!),
          ),
        };
      });
    }
  }

  void _drawRoute() async {
    if (_initialPosition == null ||
        _destinationLatitude == null ||
        _destinationLongitude == null) return;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_initialPosition!.latitude},${_initialPosition!.longitude}&destination=$_destinationLatitude,$_destinationLongitude&key=$googleMapApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];

          if (points != null && points.isNotEmpty) {
            List<LatLng> polylineCoordinates = _decodePolyline(points);

            if (mounted) {
              setState(() {
                _polylines = {
                  Polyline(
                    polylineId: PolylineId('route'),
                    visible: true,
                    points: polylineCoordinates,
                    width: 5,
                    color: Colors.blue,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
                };
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error drawing route: $e");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  void _checkArrival() {
    if (_initialPosition == null ||
        _destinationLatitude == null ||
        _destinationLongitude == null) return;

    final distance = Geolocator.distanceBetween(
      _initialPosition!.latitude,
      _initialPosition!.longitude,
      _destinationLatitude!,
      _destinationLongitude!,
    );

    if (distance < 100 && !_isDialogShown) {
      _isDialogShown = true;
      _showArrivalDialog();
    }
  }

  void _showArrivalDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextApp(
            text: 'Bạn đã đến nơi!',
            fontsize: 16.sp,
            color: Colors.black,
          ),
          content: TextApp(
            maxLines: 3,
            text: widget.detailsOrderPickUp.data.orderPickupStatus == 3
                ? 'Đã đến nơi nhận đơn, vui lòng cập nhật trạng thái của đơn hàng'
                : 'Bạn đã nhận đơn, vui lòng cập nhật trạng thái Đã Pick Up cho đơn hàng',
            fontsize: 14.sp,
            color: Colors.black,
          ),
          actions: <Widget>[
            ButtonApp(
              event: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Open the UpdateStatusOrderShipper modal and wait for result
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.r),
                      topLeft: Radius.circular(15.r),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return UpdateStatusOrderShipper(
                      detailsOrderPickUp: widget.detailsOrderPickUp,
                    );
                  },
                );
              },
              text: 'OK',
              colorText: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              outlineColor: Theme.of(context).colorScheme.primary,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        title: TextApp(
          text: "Pickup Đơn Hàng",
          fontsize: 20.sp,
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChooseBranchReturnBloc, ChooseBranchReturnState>(
            listener: (context, state) {
              if (state is ChooseBranchReturnStateMade) {
                setState(() {
                  _destinationLatitude = state.selectedBranch.latitude;
                  _destinationLongitude = state.selectedBranch.longitude;
                  _isDialogShown = false;
                  _saveDestination(
                      _destinationLatitude!, _destinationLongitude!);
                });
                _updateMarkers();
                _drawRoute();
              }
            },
          ),
        ],
        child: BlocBuilder<ChooseBranchReturnBloc, ChooseBranchReturnState>(
          builder: (context, state) {
            return Stack(
              children: [
                if (_isMapReady && _initialPosition != null)
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition!,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                  )
                else
                  Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }
}
