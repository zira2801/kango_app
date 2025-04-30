import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details/details_order_pickup_bloc.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/order_pickup/details_order_pick_up.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;

class TrackingOrderPickupMap extends StatefulWidget {
  final int orderPickupID;

  TrackingOrderPickupMap({required this.orderPickupID, super.key});
  @override
  _TrackingOrderPickupMapState createState() => _TrackingOrderPickupMapState();
}

class _TrackingOrderPickupMapState extends State<TrackingOrderPickupMap> {
  DetailsOrderPickUpModel? detailsOrderPickUp;
  GoogleMapController? mapController;
  LatLng? _orderPickUpPosition;
  double longitudeBranch = 106.6684377;
  double latitudeBranch = 10.8349986;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapReady = false;
  late BitmapDescriptor _customMarkerCompany;
  late BitmapDescriptor _customMarkerShipper;
  BranchResponse? branchResponse;

  static const String _isolatePortName = 'ShipperMarkerUpdate';
  ReceivePort? _receivePort;
  Isolate? _isolate;
  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      setState(() {
        branchResponse =
            BranchResponse.fromJson(jsonDecode(branchResponseJson));

        if (detailsOrderPickUp != null) {
          BranchKango selectedBranch = branchResponse!.branchs.firstWhere(
            (branch) => branch.branchId == detailsOrderPickUp!.data.branchId,
          );

          latitudeBranch = double.parse(selectedBranch.branchLatitude!);
          longitudeBranch = double.parse(selectedBranch.branchLongitude!);
        } else {
          log("detailsOrderPickUp NULL");
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInit();
    _initializeMap();
    _setCustomMarkerShipper();
    _setCustomMarkerCompany();
    _initIsolate();
  }

  void _initIsolate() async {
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
        _receivePort!.sendPort, _isolatePortName);
    _receivePort!.listen(_handleIsolateMessage);
    _isolate = await Isolate.spawn(_isolateEntryPoint, null);
  }

  static void _isolateEntryPoint(_) {
    final sendPort = IsolateNameServer.lookupPortByName(_isolatePortName);
    Timer.periodic(Duration(seconds: 5), (_) {
      if (sendPort != null) {
        sendPort.send('update');
      }
    });
  }

  void _handleIsolateMessage(dynamic message) {
    if (message == 'update') {
      getInit();
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    _isolate?.kill(priority: Isolate.immediate);
    IsolateNameServer.removePortNameMapping(_isolatePortName);
    _receivePort?.close();
    super.dispose();
  }

  Future<void> onGetDetailsOrderPickup() async {
    context.read<DetailsOrderPickupBloc>().add(
          HanldeGetDetailsOrderPickup(orderPickupID: widget.orderPickupID),
        );
  }

  Future<void> getInit() async {
    await onGetDetailsOrderPickup();
    await getBranchKango();
  }

  Future<void> _initializeMap() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Map initialization logic
  }

  Future<void> _setCustomMarkerShipper() async {
    _customMarkerShipper = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(4, 4)),
      'assets/images/shipper_kango_2_70x70.png',
    );
  }

  Future<void> _setCustomMarkerCompany() async {
    _customMarkerCompany = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(4, 4)),
      'assets/images/warehouse_kango_2_70x70.png',
    );
  }

  Future<void> _drawRoute() async {
    if (detailsOrderPickUp?.data.shipper == null) return;

    // Lấy vị trí shipper (điểm bắt đầu)
    final shipperPosition = LatLng(
        double.parse(detailsOrderPickUp!.data.shipper!.shipperLatitude!),
        double.parse(detailsOrderPickUp!.data.shipper!.shipperLongitude!));

    // Lấy vị trí đơn hàng (điểm đích)
    final orderPosition = LatLng(
        double.parse(detailsOrderPickUp!.data.latitude),
        double.parse(detailsOrderPickUp!.data.longitude));

    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/directions/json?'
            'origin=${shipperPosition.latitude},${shipperPosition.longitude}'
            '&destination=${orderPosition.latitude},${orderPosition.longitude}'
            '&key=$googleMapApiKey');

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
                    visible: false,
                    points: polylineCoordinates,
                    width: 5,
                    color: Colors.blue,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
                };
              });
            }
          } else {
            log("Polyline points are empty.");
          }
        } else {
          log("No routes found in the response.");
        }
      } else {
        log("Failed to fetch directions: ${response.statusCode}");
      }
    } catch (e) {
      log("Error drawing route: $e");
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

  void _updateMarkers() {
    if (detailsOrderPickUp == null) return;
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('currentOrderLocation'),
          position: LatLng(double.parse(detailsOrderPickUp!.data.latitude),
              double.parse(detailsOrderPickUp!.data.longitude)),
        ),
        Marker(
          markerId: MarkerId('currentShipperLocation'),
          position: LatLng(
              double.parse(detailsOrderPickUp!.data.shipper!.shipperLatitude!),
              double.parse(
                  detailsOrderPickUp!.data.shipper!.shipperLongitude!)),
          icon: _customMarkerShipper,
        ),
        Marker(
          markerId: MarkerId('destinationLocation'),
          position: LatLng(latitudeBranch, longitudeBranch),
          icon: _customMarkerCompany,
        ),
      };
    });
  }

  void _updateShipperMarker() async {
    if (detailsOrderPickUp == null) return;
    final updatedMarker = Marker(
      markerId: const MarkerId('currentShipperLocation'),
      position: LatLng(
        double.parse(detailsOrderPickUp!.data.shipper!.shipperLatitude!),
        double.parse(detailsOrderPickUp!.data.shipper!.shipperLongitude!),
      ),
      icon: _customMarkerShipper,
    );

    setState(() {
      _markers.removeWhere(
          (marker) => marker.markerId.value == 'currentShipperLocation');
      _markers.add(updatedMarker);
    });
// Cập nhật route khi shipper di chuyển
    await _drawRoute();
    log("shipperLatitude");
    log(detailsOrderPickUp!.data.shipper!.shipperLatitude!);
    log("shipperLongitude");
    log(detailsOrderPickUp!.data.shipper!.shipperLongitude!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        title: TextApp(
          text: "Đơn Hàng Pickup",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DetailsOrderPickupBloc, DetailsOrderPickupState>(
            listener: (context, state) {
              if (state is HanldeGetDetailsOrderPickupSuccess) {
                setState(() {
                  detailsOrderPickUp = state.detailsOrderPickUpModel;
                  _orderPickUpPosition = LatLng(
                      double.parse(state.detailsOrderPickUpModel.data.latitude),
                      double.parse(
                          state.detailsOrderPickUpModel.data.longitude));
                });
                getBranchKango();
                if (_markers.isEmpty) {
                  _updateMarkers(); // Initial setup of all markers
                  _drawRoute(); // Initial route drawing
                } else {
                  _updateShipperMarker(); // Update only shipper's marker and route
                }
              }
            },
          ),
        ],
        child: BlocBuilder<DetailsOrderPickupBloc, DetailsOrderPickupState>(
          builder: (context, state) {
            if (_orderPickUpPosition != null) {
              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _orderPickUpPosition!,
                  zoom: 14.0,
                ),
                markers: _markers,
                polylines: _polylines,
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
