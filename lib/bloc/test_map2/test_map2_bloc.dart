import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'test_map2_event.dart';
import 'test_map2_state.dart';

class MapBloc2 extends Bloc<MapEvent2, MapState2> {
  MapBloc2() : super(MapInitial()) {
    on<SearchLocation>(_onSearchLocation);
    on<SelectPlace>(_onSelectPlace);
    on<FetchLocationDetails>(_onFetchLocationDetails);
    on<UpdateSelectedPosition>(_onUpdateSelectedPosition);
  }

  Future<void> _onSearchLocation(
      SearchLocation event, Emitter<MapState2> emit) async {
    emit(MapLoading());
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${event.query}&key=$googleMapApiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        emit(MapLoadSuccess(data['predictions']));
      } else {
        emit(MapLoadFailure(data['status']));
      }
    } else {
      emit(MapLoadFailure('Failed to load predictions'));
    }
  }

  Future<void> _onSelectPlace(
      SelectPlace event, Emitter<MapState2> emit) async {
    emit(MapLoading());
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${event.placeId}&key=$googleMapApiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log(data['result']['formatted_address'].toString());
      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        final description = data['result']
            ['formatted_address']; // Assuming 'name' holds the location name.
        log("NAME LOCATION $description");
        emit(PlaceSelected(location['lat'], location['lng'], description));
      } else {
        emit(MapLoadFailure(data['status']));
      }
    } else {
      emit(MapLoadFailure('Failed to load place details'));
    }
  }

  Future<void> _onFetchLocationDetails(
      FetchLocationDetails event, Emitter<MapState2> emit) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${event.latitude},${event.longitude}&key=$googleMapApiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final address = data['results'][0]['formatted_address'];
        emit(LocationDetailsFetched(address));
      } else {
        emit(MapLoadFailure(data['status']));
      }
    } else {
      emit(MapLoadFailure('Failed to load location details'));
    }
  }

  void _onUpdateSelectedPosition(
      UpdateSelectedPosition event, Emitter<MapState2> emit) {
    emit(PlaceSelected(event.latitude, event.longitude, event.description));
    add(FetchLocationDetails(event.latitude, event.longitude));
  }
}
