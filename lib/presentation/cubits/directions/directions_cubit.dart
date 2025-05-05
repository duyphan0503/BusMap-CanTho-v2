import 'package:busmapcantho/configs/env.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

part 'directions_state.dart';

@injectable
class DirectionsCubit extends Cubit<DirectionsState> {
  DirectionsCubit() : super(DirectionsInitial());

  Future<void> getRoute(LatLng start, LatLng end) async {
    emit(DirectionsLoading());
    try {
      final apiKey = const String.fromEnvironment(googleMapsApiKey);
      /*final poly = PolylinePoints();
      final result = await poly.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(end.latitude, end.longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isEmpty) {
        emit(DirectionsError('No route found'));
      } else {
        final points =
            result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        emit(DirectionsLoaded(polylinePoints: points));
      }*/
    } catch (e) {
      emit(DirectionsError('Error fetching route: $e'));
    }
  }
}
