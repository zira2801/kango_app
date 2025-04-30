import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:equatable/equatable.dart';
part 'map_shipper_event.dart';
part 'map_shipper_state.dart';

class MapShipperBloc extends Bloc<MapShipperEvent, MapShipperState> {
  MapShipperBloc() : super(MapShipperStateInitial()) {
    on<HanldeMapShipper>(_onHanldeMapShipper);
  }

  Future<void> _onHanldeMapShipper(
    HanldeMapShipper event,
    Emitter<MapShipperState> emit,
  ) async {
    emit(MapShipperStateLoading());
  }
}
