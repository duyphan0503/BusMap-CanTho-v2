import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/model/bus_route.dart';
import '../../../../domain/usecases/bus_route/get_all_bus_routes_usecase.dart';
import '../../../../domain/usecases/bus_route/get_bus_route_by_id_usecase.dart';
import 'bus_route_state.dart';

class BusRouteCubit extends Cubit<BusRouteState> {
  final GetAllBusRoutesUseCase _getAllBusRoute;
  final GetBusRouteByIdUseCase _getBusRouteById;

  BusRouteCubit(this._getAllBusRoute, this._getBusRouteById)
    : super(BusRouteInitial());

  Future<void> fetchAllBusRoutes() async {
    emit(BusRouteLoading());
    try {
      final routes = await _getAllBusRoute();
      emit(BusRouteLoaded(routes));
    } catch (e) {
      emit(BusRouteError(e.toString()));
    }
  }

  Future<BusRoute?> fetchBusRouteById(String id) async {
    try {
      return await _getBusRouteById(id);
    } catch (e) {
      emit(BusRouteError(e.toString()));
      return null;
    }
  }
}
