// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:busmapcantho/core/di/register_module.dart' as _i609;
import 'package:busmapcantho/data/datasources/agency_remote_datasource.dart'
    as _i848;
import 'package:busmapcantho/data/datasources/auth_remote_datasource.dart'
    as _i1019;
import 'package:busmapcantho/data/datasources/bus_location_remote_datasource.dart'
    as _i662;
import 'package:busmapcantho/data/datasources/bus_route_remote_datasource.dart'
    as _i628;
import 'package:busmapcantho/data/datasources/bus_stop_remote_datasource.dart'
    as _i257;
import 'package:busmapcantho/data/datasources/favorite_route_remote_datasource.dart'
    as _i553;
import 'package:busmapcantho/data/datasources/feedback_remote_datasource.dart'
    as _i502;
import 'package:busmapcantho/data/datasources/notification_remote_datasource.dart'
    as _i962;
import 'package:busmapcantho/data/datasources/route_stop_remote_datasource.dart'
    as _i68;
import 'package:busmapcantho/data/datasources/search_history_remote_datasource.dart'
    as _i649;
import 'package:busmapcantho/data/datasources/ticket_remote_datasource.dart'
    as _i366;
import 'package:busmapcantho/data/datasources/user_favorite_remote_datasource.dart'
    as _i761;
import 'package:busmapcantho/data/repositories/agency_repository.dart' as _i638;
import 'package:busmapcantho/data/repositories/auth_repository_impl.dart'
    as _i736;
import 'package:busmapcantho/data/repositories/bus_location_repository.dart'
    as _i530;
import 'package:busmapcantho/data/repositories/bus_route_repository.dart'
    as _i705;
import 'package:busmapcantho/data/repositories/bus_stop_repository.dart'
    as _i16;
import 'package:busmapcantho/data/repositories/favorite_route_repository.dart'
    as _i309;
import 'package:busmapcantho/data/repositories/feedback_repository.dart'
    as _i566;
import 'package:busmapcantho/data/repositories/notification_repository.dart'
    as _i773;
import 'package:busmapcantho/data/repositories/route_stops_repository.dart'
    as _i730;
import 'package:busmapcantho/data/repositories/search_history_repository.dart'
    as _i101;
import 'package:busmapcantho/data/repositories/ticket_repository.dart' as _i988;
import 'package:busmapcantho/data/repositories/user_favorite_repository.dart'
    as _i335;
import 'package:busmapcantho/domain/repositories/auth_repository.dart' as _i556;
import 'package:busmapcantho/domain/usecases/auth/change_password_usecase.dart'
    as _i666;
import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart'
    as _i264;
import 'package:busmapcantho/domain/usecases/auth/google_sign_in_native_usecase.dart'
    as _i686;
import 'package:busmapcantho/domain/usecases/auth/request_password_reset_otp_usecase.dart'
    as _i405;
import 'package:busmapcantho/domain/usecases/auth/reset_password_with_otp_usecase.dart'
    as _i81;
import 'package:busmapcantho/domain/usecases/auth/sign_in_usecase.dart'
    as _i995;
import 'package:busmapcantho/domain/usecases/auth/sign_out_usecase.dart'
    as _i284;
import 'package:busmapcantho/domain/usecases/auth/sign_up_usecase.dart'
    as _i421;
import 'package:busmapcantho/domain/usecases/auth/update_display_name_usecase.dart'
    as _i346;
import 'package:busmapcantho/domain/usecases/auth/update_profile_image_usecase.dart'
    as _i1067;
import 'package:busmapcantho/domain/usecases/auth/verify_email_otp_usecase.dart'
    as _i725;
import 'package:busmapcantho/domain/usecases/bus_route/get_all_bus_routes_usecase.dart'
    as _i298;
import 'package:busmapcantho/domain/usecases/bus_stop/get_all_bus_stops_usecase.dart'
    as _i797;
import 'package:busmapcantho/domain/usecases/bus_stop/get_bus_stop_by_id_usecase.dart'
    as _i345;
import 'package:busmapcantho/domain/usecases/favorite/get_favorite_routes_usecase.dart'
    as _i774;
import 'package:busmapcantho/domain/usecases/favorite/remove_favorite_routes_usecase.dart'
    as _i511;
import 'package:busmapcantho/domain/usecases/favorite/save_favorite_route_usecase.dart'
    as _i451;
import 'package:busmapcantho/presentation/cubits/account/account_cubit.dart'
    as _i601;
import 'package:busmapcantho/presentation/cubits/auth/auth_cubit.dart' as _i122;
import 'package:busmapcantho/presentation/cubits/directions/directions_cubit.dart'
    as _i752;
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart'
    as _i166;
import 'package:busmapcantho/presentation/cubits/map/map_cubit.dart' as _i962;
import 'package:busmapcantho/presentation/cubits/routes/routes_cubit.dart'
    as _i619;
import 'package:busmapcantho/presentation/cubits/search/search_cubit.dart'
    as _i907;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i752.DirectionsCubit>(() => _i752.DirectionsCubit());
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i649.SearchHistoryRemoteDatasource>(
      () => _i649.SearchHistoryRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i1019.AuthRemoteDatasource>(
      () => _i1019.AuthRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i628.BusRouteRemoteDatasource>(
      () => _i628.BusRouteRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i502.FeedbackRemoteDatasource>(
      () => _i502.FeedbackRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i68.RouteStopRemoteDatasource>(
      () => _i68.RouteStopRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i962.NotificationRemoteDatasource>(
      () => _i962.NotificationRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i553.FavoriteRouteRemoteDatasource>(
      () => _i553.FavoriteRouteRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i366.TicketRemoteDatasource>(
      () => _i366.TicketRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i257.BusStopRemoteDatasource>(
      () => _i257.BusStopRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i761.UserFavoriteRemoteDatasource>(
      () => _i761.UserFavoriteRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i662.BusLocationRemoteDatasource>(
      () => _i662.BusLocationRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i848.AgencyRemoteDatasource>(
      () => _i848.AgencyRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i730.RouteStopsRepository>(
      () => _i730.RouteStopsRepository(gh<_i68.RouteStopRemoteDatasource>()),
    );
    gh.lazySingleton<_i335.UserFavoriteRepository>(
      () => _i335.UserFavoriteRepository(
        gh<_i761.UserFavoriteRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i773.NotificationRepository>(
      () => _i773.NotificationRepository(
        gh<_i962.NotificationRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i16.BusStopRepository>(
      () => _i16.BusStopRepository(
        gh<_i257.BusStopRemoteDatasource>(),
        gh<_i68.RouteStopRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i530.BusLocationRepository>(
      () =>
          _i530.BusLocationRepository(gh<_i662.BusLocationRemoteDatasource>()),
    );
    gh.factory<_i962.MapCubit>(
      () => _i962.MapCubit(gh<_i16.BusStopRepository>()),
    );
    gh.lazySingleton<_i556.AuthRepository>(
      () => _i736.AuthRepositoryImpl(gh<_i1019.AuthRemoteDatasource>()),
    );
    gh.lazySingleton<_i101.SearchHistoryRepository>(
      () => _i101.SearchHistoryRepository(
        gh<_i649.SearchHistoryRemoteDatasource>(),
      ),
    );
    gh.factory<_i345.GetBusStopByIdUseCase>(
      () => _i345.GetBusStopByIdUseCase(gh<_i16.BusStopRepository>()),
    );
    gh.factory<_i797.GetAllBusStopsUseCase>(
      () => _i797.GetAllBusStopsUseCase(gh<_i16.BusStopRepository>()),
    );
    gh.lazySingleton<_i705.BusRouteRepository>(
      () => _i705.BusRouteRepository(gh<_i628.BusRouteRemoteDatasource>()),
    );
    gh.lazySingleton<_i638.AgencyRepository>(
      () => _i638.AgencyRepository(gh<_i848.AgencyRemoteDatasource>()),
    );
    gh.lazySingleton<_i309.FavoriteRouteRepository>(
      () => _i309.FavoriteRouteRepository(
        gh<_i553.FavoriteRouteRemoteDatasource>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.lazySingleton<_i566.FeedbackRepository>(
      () => _i566.FeedbackRepository(gh<_i502.FeedbackRemoteDatasource>()),
    );
    gh.factory<_i619.RoutesCubit>(
      () => _i619.RoutesCubit(
        gh<_i705.BusRouteRepository>(),
        gh<_i309.FavoriteRouteRepository>(),
        gh<_i730.RouteStopsRepository>(),
      ),
    );
    gh.lazySingleton<_i988.TicketRepository>(
      () => _i988.TicketRepository(gh<_i366.TicketRemoteDatasource>()),
    );
    gh.factory<_i298.GetAllBusRoutesUseCase>(
      () => _i298.GetAllBusRoutesUseCase(gh<_i705.BusRouteRepository>()),
    );
    gh.factory<_i451.SaveFavoriteRouteUseCase>(
      () => _i451.SaveFavoriteRouteUseCase(gh<_i309.FavoriteRouteRepository>()),
    );
    gh.factory<_i511.RemoveFavoriteRouteUseCase>(
      () =>
          _i511.RemoveFavoriteRouteUseCase(gh<_i309.FavoriteRouteRepository>()),
    );
    gh.factory<_i907.SearchCubit>(
      () => _i907.SearchCubit(
        gh<_i705.BusRouteRepository>(),
        gh<_i16.BusStopRepository>(),
        gh<_i101.SearchHistoryRepository>(),
      ),
    );
    gh.factory<_i421.SignUpUseCase>(
      () => _i421.SignUpUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i405.RequestPasswordResetOtpUseCase>(
      () => _i405.RequestPasswordResetOtpUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i346.UpdateDisplayNameUseCase>(
      () => _i346.UpdateDisplayNameUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i725.VerifyEmailOtpUseCase>(
      () => _i725.VerifyEmailOtpUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i264.GetCurrentUserUseCase>(
      () => _i264.GetCurrentUserUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i666.ChangePasswordUseCase>(
      () => _i666.ChangePasswordUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i995.SignInUseCase>(
      () => _i995.SignInUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i81.ResetPasswordWithOtpUseCase>(
      () => _i81.ResetPasswordWithOtpUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i1067.UpdateProfileImageUseCase>(
      () => _i1067.UpdateProfileImageUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i284.SignOutUseCase>(
      () => _i284.SignOutUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i686.GoogleSignInNativeUseCase>(
      () => _i686.GoogleSignInNativeUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i166.FavoritesCubit>(
      () => _i166.FavoritesCubit(
        gh<_i309.FavoriteRouteRepository>(),
        gh<_i335.UserFavoriteRepository>(),
      ),
    );
    gh.factory<_i601.AccountCubit>(
      () => _i601.AccountCubit(
        getCurrentUserUseCase: gh<_i264.GetCurrentUserUseCase>(),
        updateDisplayNameUseCase: gh<_i346.UpdateDisplayNameUseCase>(),
        updateProfileImageUseCase: gh<_i1067.UpdateProfileImageUseCase>(),
        changePasswordUseCase: gh<_i666.ChangePasswordUseCase>(),
        signOutUseCase: gh<_i284.SignOutUseCase>(),
      ),
    );
    gh.factory<_i774.GetFavoriteRoutesUseCase>(
      () => _i774.GetFavoriteRoutesUseCase(
        gh<_i309.FavoriteRouteRepository>(),
        gh<_i264.GetCurrentUserUseCase>(),
      ),
    );
    gh.factory<_i122.AuthCubit>(
      () => _i122.AuthCubit(
        gh<_i264.GetCurrentUserUseCase>(),
        gh<_i421.SignUpUseCase>(),
        gh<_i995.SignInUseCase>(),
        gh<_i686.GoogleSignInNativeUseCase>(),
        gh<_i284.SignOutUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i609.RegisterModule {}
