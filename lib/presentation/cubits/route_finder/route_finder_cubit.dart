import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@injectable
class RouteFinderCubit extends Cubit<RouteFinderState> {
  RouteFinderCubit() : super(RouteFinderState.initial());

  void setInitialLocation(LatLng? userLocation) {
    if (userLocation != null && state.startLatLng == null && state.startName == null) {
      emit(state.copyWith(startLatLng: userLocation, startName: 'Vị trí của bạn'));
    }
  }

  void setStart({String? name, LatLng? latLng}) {
    emit(
      state.copyWith(
        startName: name,
        startLatLng: latLng,
        selectionType: LocationSelectionType.none,
      ),
    );
    _drawLineIfReady();
  }

  void setEnd({String? name, LatLng? latLng}) {
    emit(
      state.copyWith(
        endName: name,
        endLatLng: latLng,
        selectionType: LocationSelectionType.none,
      ),
    );
    _drawLineIfReady();
  }

  void swap() {
    emit(
      state.copyWith(
        startName: state.endName,
        startLatLng: state.endLatLng,
        endName: state.startName,
        endLatLng: state.startLatLng,
      ),
    );
    _drawLineIfReady();
  }

  // Set selection type to start when selecting start location
  void selectingStart() {
    emit(state.copyWith(selectionType: LocationSelectionType.start));
  }

  // Set selection type to end when selecting end location
  void selectingEnd() {
    emit(state.copyWith(selectionType: LocationSelectionType.end));
  }

  // Reset selection type
  void resetSelection() {
    emit(state.copyWith(selectionType: LocationSelectionType.none));
  }

  void _drawLineIfReady() {
    if (state.startLatLng != null && state.endLatLng != null) {
      emit(state.copyWith(routeLine: [state.startLatLng!, state.endLatLng!]));
    } else {
      emit(state.copyWith(routeLine: []));
    }
  }
}
