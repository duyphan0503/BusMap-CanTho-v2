import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@injectable
class RouteFinderCubit extends Cubit<RouteFinderState> {
  RouteFinderCubit() : super(RouteFinderState.initial());

  void setInitialLocation(LatLng? userLocation, [String? translatedName]) {
    if (userLocation != null && state.startLatLng == null && state.startName == null) {
      emit(state.copyWith(
        startLatLng: userLocation,
        startName: translatedName,
        startInputError: false, // Clear error on new input
        endInputError: false,
      ));
      _drawLineIfReady();
    }
  }

  // Clear all route data
  void resetRoute() {
    emit(RouteFinderState.initial());
  }

  void setStart({String? name, LatLng? latLng}) {
    emit(
      state.copyWith(
        startName: name,
        startLatLng: latLng,
        selectionType: LocationSelectionType.none,
        startInputError: false, // Clear error on new input
        endInputError: (name == null || name.isEmpty) && (latLng == null) ? state.endInputError : false,
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
        endInputError: false, // Clear error on new input
        startInputError: (name == null || name.isEmpty) && (latLng == null) ? state.startInputError : false,
      ),
    );
    _drawLineIfReady();
  }

  void swap() {
    bool canSwap = true;
    bool newStartError = false;
    bool newEndError = false;

    if (state.startName == null || state.startName!.isEmpty && state.startLatLng == null) {
      canSwap = false;
      newStartError = true;
    }
    if (state.endName == null || state.endName!.isEmpty && state.endLatLng == null) {
      canSwap = false;
      newEndError = true;
    }

    if (canSwap) {
      emit(
        state.copyWith(
          startName: state.endName,
          startLatLng: state.endLatLng,
          endName: state.startName,
          endLatLng: state.startLatLng,
          startInputError: false, // Clear errors on successful swap
          endInputError: false,
        ),
      );
      _drawLineIfReady();
    } else {
      emit(state.copyWith(startInputError: newStartError, endInputError: newEndError));
      // Optionally, clear errors after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (state.startInputError || state.endInputError) { // Check if errors are still present
            emit(state.copyWith(startInputError: false, endInputError: false));
        }
      });
    }
  }

  // Set selection type to start when selecting start location
  void selectingStart() {
    emit(state.copyWith(selectionType: LocationSelectionType.start, startInputError: false, endInputError: false));
  }

  // Set selection type to end when selecting end location
  void selectingEnd() {
    emit(state.copyWith(selectionType: LocationSelectionType.end, startInputError: false, endInputError: false));
  }

  // Reset selection type
  void resetSelection() {
    emit(state.copyWith(selectionType: LocationSelectionType.none, startInputError: false, endInputError: false));
  }

  void _drawLineIfReady() {
    if (state.startLatLng != null && state.endLatLng != null) {
      emit(state.copyWith(routeLine: [state.startLatLng!, state.endLatLng!]));
    } else {
      // Keep existing partial line logic or clear if preferred
      final List<LatLng> partialLine = [];
      if (state.startLatLng != null) partialLine.add(state.startLatLng!);
      if (state.endLatLng != null) partialLine.add(state.endLatLng!);
      emit(state.copyWith(routeLine: partialLine));
    }
  }
}
