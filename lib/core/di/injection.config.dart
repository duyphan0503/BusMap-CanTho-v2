// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:busmapcantho/core/di/logger_module.dart' as _i876;
import 'package:busmapcantho/core/di/notification_module.dart' as _i673;
import 'package:busmapcantho/core/di/supabase_module.dart' as _i1057;
import 'package:busmapcantho/core/services/bus_realtime_service.dart' as _i290;
import 'package:busmapcantho/core/services/notification_local_service.dart'
    as _i67;
import 'package:busmapcantho/core/services/osrm_service.dart' as _i1030;
import 'package:busmapcantho/core/services/places_service.dart' as _i875;
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
import 'package:busmapcantho/data/repositories/feedback_repository.dart'
    as _i566;
import 'package:busmapcantho/data/repositories/notification_repository_impl.dart'
    as _i590;
import 'package:busmapcantho/data/repositories/route_stops_repository.dart'
    as _i730;
import 'package:busmapcantho/data/repositories/search_history_repository.dart'
    as _i101;
import 'package:busmapcantho/data/repositories/ticket_repository.dart' as _i988;
import 'package:busmapcantho/data/repositories/user_favorite_repository.dart'
    as _i335;
import 'package:busmapcantho/domain/repositories/auth_repository.dart' as _i556;
import 'package:busmapcantho/domain/repositories/notification_repository.dart'
    as _i287;
import 'package:busmapcantho/domain/usecases/auth/change_password_usecase.dart'
    as _i666;
import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart'
    as _i264;
import 'package:busmapcantho/domain/usecases/auth/get_user_profile_usecase.dart'
    as _i909;
import 'package:busmapcantho/domain/usecases/auth/google_sign_in_native_usecase.dart'
    as _i686;
import 'package:busmapcantho/domain/usecases/auth/request_password_reset_otp_usecase.dart'
    as _i405;
import 'package:busmapcantho/domain/usecases/auth/resend_email_otp_usecase.dart'
    as _i943;
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
import 'package:busmapcantho/domain/usecases/bus_routes/get_all_bus_routes_usecase.dart'
    as _i1049;
import 'package:busmapcantho/domain/usecases/bus_routes/get_bus_route_by_id_usecase.dart'
    as _i422;
import 'package:busmapcantho/domain/usecases/bus_routes/search_bus_routes_usecase.dart'
    as _i111;
import 'package:busmapcantho/domain/usecases/bus_stops/get_all_bus_stops_usecase.dart'
    as _i950;
import 'package:busmapcantho/domain/usecases/bus_stops/get_bus_stop_by_id_usecase.dart'
    as _i60;
import 'package:busmapcantho/domain/usecases/bus_stops/get_nearby_bus_stops_usecase.dart'
    as _i753;
import 'package:busmapcantho/domain/usecases/favorite/add_favorite_route_usecase.dart'
    as _i1;
import 'package:busmapcantho/domain/usecases/favorite/add_favorite_stop_usecase.dart'
    as _i628;
import 'package:busmapcantho/domain/usecases/favorite/get_favorite_routes_usecase.dart'
    as _i774;
import 'package:busmapcantho/domain/usecases/favorite/get_favorite_stops_usecase.dart'
    as _i302;
import 'package:busmapcantho/domain/usecases/favorite/remove_favorite_usecase.dart'
    as _i242;
import 'package:busmapcantho/domain/usecases/feedback/get_current_user_feedback_for_route_usecase.dart'
    as _i40;
import 'package:busmapcantho/domain/usecases/feedback/get_feedbacks_by_route_excluding_current_user_usecase.dart'
    as _i685;
import 'package:busmapcantho/domain/usecases/feedback/send_feedback_usecase.dart'
    as _i3;
import 'package:busmapcantho/domain/usecases/feedback/update_feedback_usecase.dart'
    as _i994;
import 'package:busmapcantho/domain/usecases/notification/delete_notification_usecase.dart'
    as _i788;
import 'package:busmapcantho/domain/usecases/notification/get_user_notifications_usecase.dart'
    as _i479;
import 'package:busmapcantho/domain/usecases/notification/monitor_stop_usecase.dart'
    as _i171;
import 'package:busmapcantho/domain/usecases/notification/report_vehicle_arrival_usecase.dart'
    as _i344;
import 'package:busmapcantho/domain/usecases/route_stops/get_route_stop_usecase.dart'
    as _i661;
import 'package:busmapcantho/domain/usecases/route_stops/get_route_stops_as_bus_stops_usecase.dart'
    as _i167;
import 'package:busmapcantho/domain/usecases/route_stops/get_route_stops_usecase.dart'
    as _i706;
import 'package:busmapcantho/domain/usecases/route_stops/get_routes_for_stop_usecase.dart'
    as _i32;
import 'package:busmapcantho/domain/usecases/route_stops/get_stop_sequence_usecase.dart'
    as _i770;
import 'package:busmapcantho/domain/usecases/route_stops/is_stop_on_route_usecase.dart'
    as _i119;
import 'package:busmapcantho/presentation/blocs/map/map_bloc.dart' as _i255;
import 'package:busmapcantho/presentation/cubits/account/account_cubit.dart'
    as _i601;
import 'package:busmapcantho/presentation/cubits/auth/auth_cubit.dart' as _i122;
import 'package:busmapcantho/presentation/cubits/bus_location/bus_location_cubit.dart'
    as _i120;
import 'package:busmapcantho/presentation/cubits/bus_routes/routes_cubit.dart'
    as _i212;
import 'package:busmapcantho/presentation/cubits/bus_stops/stop_cubit.dart'
    as _i840;
import 'package:busmapcantho/presentation/cubits/directions/directions_cubit.dart'
    as _i752;
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart'
    as _i166;
import 'package:busmapcantho/presentation/cubits/feedback/feedback_cubit.dart'
    as _i839;
import 'package:busmapcantho/presentation/cubits/notification/notification_cubit.dart'
    as _i129;
import 'package:busmapcantho/presentation/cubits/otp/otp_cubit.dart' as _i415;
import 'package:busmapcantho/presentation/cubits/password/password_cubit.dart'
    as _i600;
import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_cubit.dart'
    as _i767;
import 'package:busmapcantho/presentation/cubits/route_stops/route_stops_cubit.dart'
    as _i655;
import 'package:busmapcantho/presentation/cubits/route_suggestion/route_suggestion_cubit.dart'
    as _i641;
import 'package:busmapcantho/presentation/cubits/search/search_cubit.dart'
    as _i907;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final notificationModule = _$NotificationModule();
    final loggerModule = _$LoggerModule();
    final registerModule = _$RegisterModule();
    gh.factory<_i1030.OsrmService>(() => _i1030.OsrmService());
    gh.factory<_i875.PlacesService>(() => _i875.PlacesService());
    gh.factory<_i255.MapBloc>(() => _i255.MapBloc());
    gh.factory<_i767.RouteFinderCubit>(() => _i767.RouteFinderCubit());
    gh.lazySingleton<_i67.NotificationLocalService>(
      () => notificationModule.notificationLocalService,
    );
    gh.lazySingleton<_i974.Logger>(() => loggerModule.logger);
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i649.SearchHistoryRemoteDatasource>(
      () => _i649.SearchHistoryRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i1019.AuthRemoteDatasource>(
      () => _i1019.AuthRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i761.UserFavoriteRemoteDatasource>(
      () => _i761.UserFavoriteRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i628.BusRouteRemoteDatasource>(
      () => _i628.BusRouteRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i662.BusLocationRemoteDatasource>(
      () => _i662.BusLocationRemoteDatasource(gh<_i454.SupabaseClient>()),
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
    gh.lazySingleton<_i366.TicketRemoteDatasource>(
      () => _i366.TicketRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i257.BusStopRemoteDatasource>(
      () => _i257.BusStopRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i848.AgencyRemoteDatasource>(
      () => _i848.AgencyRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i290.BusRealtimeService>(
      () => _i290.BusRealtimeService(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i730.RouteStopsRepository>(
      () => _i730.RouteStopsRepository(gh<_i68.RouteStopRemoteDatasource>()),
    );
    gh.lazySingleton<_i335.UserFavoriteRepository>(
      () => _i335.UserFavoriteRepository(
        gh<_i761.UserFavoriteRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i287.NotificationRepository>(
      () => _i590.NotificationRepositoryImpl(
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
    gh.factory<_i242.RemoveFavoriteUseCase>(
      () => _i242.RemoveFavoriteUseCase(gh<_i335.UserFavoriteRepository>()),
    );
    gh.lazySingleton<_i556.AuthRepository>(
      () => _i736.AuthRepositoryImpl(gh<_i1019.AuthRemoteDatasource>()),
    );
    gh.factory<_i479.GetUserNotificationsUseCase>(
      () =>
          _i479.GetUserNotificationsUseCase(gh<_i287.NotificationRepository>()),
    );
    gh.lazySingleton<_i101.SearchHistoryRepository>(
      () => _i101.SearchHistoryRepository(
        gh<_i649.SearchHistoryRemoteDatasource>(),
      ),
    );
    gh.factory<_i60.GetBusStopByIdUseCase>(
      () => _i60.GetBusStopByIdUseCase(gh<_i16.BusStopRepository>()),
    );
    gh.factory<_i950.GetAllBusStopsUseCase>(
      () => _i950.GetAllBusStopsUseCase(gh<_i16.BusStopRepository>()),
    );
    gh.factory<_i706.GetRouteStopsUseCase>(
      () => _i706.GetRouteStopsUseCase(gh<_i730.RouteStopsRepository>()),
    );
    gh.factory<_i770.GetStopSequenceUseCase>(
      () => _i770.GetStopSequenceUseCase(gh<_i730.RouteStopsRepository>()),
    );
    gh.factory<_i661.GetRouteStopUseCase>(
      () => _i661.GetRouteStopUseCase(gh<_i730.RouteStopsRepository>()),
    );
    gh.factory<_i32.GetRoutesForStopUseCase>(
      () => _i32.GetRoutesForStopUseCase(gh<_i730.RouteStopsRepository>()),
    );
    gh.factory<_i119.IsStopOnRouteUseCase>(
      () => _i119.IsStopOnRouteUseCase(gh<_i730.RouteStopsRepository>()),
    );
    gh.factory<_i167.GetRouteStopsAsBusStopsUseCase>(
      () => _i167.GetRouteStopsAsBusStopsUseCase(
        gh<_i730.RouteStopsRepository>(),
      ),
    );
    gh.factory<_i753.GetNearbyBusStopsUseCase>(
      () => _i753.GetNearbyBusStopsUseCase(gh<_i16.BusStopRepository>()),
    );
    gh.factory<_i752.DirectionsCubit>(
      () => _i752.DirectionsCubit(gh<_i1030.OsrmService>()),
    );
    gh.lazySingleton<_i705.BusRouteRepository>(
      () => _i705.BusRouteRepository(gh<_i628.BusRouteRemoteDatasource>()),
    );
    gh.lazySingleton<_i638.AgencyRepository>(
      () => _i638.AgencyRepository(gh<_i848.AgencyRemoteDatasource>()),
    );
    gh.lazySingleton<_i566.FeedbackRepository>(
      () => _i566.FeedbackRepository(gh<_i502.FeedbackRemoteDatasource>()),
    );
    gh.factory<_i120.BusLocationCubit>(
      () => _i120.BusLocationCubit(gh<_i290.BusRealtimeService>()),
    );
    gh.factory<_i788.DeleteNotificationUseCase>(
      () => _i788.DeleteNotificationUseCase(gh<_i287.NotificationRepository>()),
    );
    gh.lazySingleton<_i988.TicketRepository>(
      () => _i988.TicketRepository(gh<_i366.TicketRemoteDatasource>()),
    );
    gh.factory<_i840.StopCubit>(
      () => _i840.StopCubit(
        gh<_i753.GetNearbyBusStopsUseCase>(),
        gh<_i950.GetAllBusStopsUseCase>(),
      ),
    );
    gh.factory<_i111.SearchBusRoutesUseCase>(
      () => _i111.SearchBusRoutesUseCase(gh<_i705.BusRouteRepository>()),
    );
    gh.factory<_i628.AddFavoriteStopUseCase>(
      () => _i628.AddFavoriteStopUseCase(gh<_i335.UserFavoriteRepository>()),
    );
    gh.factory<_i302.GetFavoriteStopsUseCase>(
      () => _i302.GetFavoriteStopsUseCase(gh<_i335.UserFavoriteRepository>()),
    );
    gh.factory<_i1.AddFavoriteRouteUseCase>(
      () => _i1.AddFavoriteRouteUseCase(gh<_i335.UserFavoriteRepository>()),
    );
    gh.factory<_i774.GetFavoriteRoutesUseCase>(
      () => _i774.GetFavoriteRoutesUseCase(gh<_i335.UserFavoriteRepository>()),
    );
    gh.factory<_i1049.GetAllBusRoutesUseCase>(
      () => _i1049.GetAllBusRoutesUseCase(gh<_i705.BusRouteRepository>()),
    );
    gh.factory<_i422.GetBusRouteByIdUseCase>(
      () => _i422.GetBusRouteByIdUseCase(gh<_i705.BusRouteRepository>()),
    );
    gh.factory<_i909.GetUserProfileUseCase>(
      () => _i909.GetUserProfileUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i166.FavoritesCubit>(
      () => _i166.FavoritesCubit(
        gh<_i774.GetFavoriteRoutesUseCase>(),
        gh<_i302.GetFavoriteStopsUseCase>(),
        gh<_i1.AddFavoriteRouteUseCase>(),
        gh<_i628.AddFavoriteStopUseCase>(),
        gh<_i242.RemoveFavoriteUseCase>(),
        gh<_i422.GetBusRouteByIdUseCase>(),
        gh<_i60.GetBusStopByIdUseCase>(),
      ),
    );
    gh.factory<_i171.MonitorStopUseCase>(
      () => _i171.MonitorStopUseCase(
        gh<_i530.BusLocationRepository>(),
        gh<_i67.NotificationLocalService>(),
      ),
    );
    gh.factory<_i344.ReportVehicleArrivalUseCase>(
      () => _i344.ReportVehicleArrivalUseCase(
        gh<_i530.BusLocationRepository>(),
        gh<_i67.NotificationLocalService>(),
      ),
    );
    gh.factory<_i943.ResendEmailOtpUseCase>(
      () => _i943.ResendEmailOtpUseCase(gh<_i556.AuthRepository>()),
    );
    gh.factory<_i212.RoutesCubit>(
      () => _i212.RoutesCubit(
        gh<_i1049.GetAllBusRoutesUseCase>(),
        gh<_i167.GetRouteStopsAsBusStopsUseCase>(),
        gh<_i111.SearchBusRoutesUseCase>(),
        gh<_i774.GetFavoriteRoutesUseCase>(),
        gh<_i974.Logger>(),
      ),
    );
    gh.factory<_i907.SearchCubit>(
      () => _i907.SearchCubit(
        gh<_i705.BusRouteRepository>(),
        gh<_i16.BusStopRepository>(),
        gh<_i101.SearchHistoryRepository>(),
      ),
    );
    gh.factory<_i994.UpdateFeedbackUseCase>(
      () => _i994.UpdateFeedbackUseCase(gh<_i566.FeedbackRepository>()),
    );
    gh.factory<_i685.GetFeedbacksByRouteExcludingCurrentUserUseCase>(
      () => _i685.GetFeedbacksByRouteExcludingCurrentUserUseCase(
        gh<_i566.FeedbackRepository>(),
      ),
    );
    gh.factory<_i3.SendFeedbackUseCase>(
      () => _i3.SendFeedbackUseCase(gh<_i566.FeedbackRepository>()),
    );
    gh.factory<_i40.GetCurrentUserFeedbackForRouteUseCase>(
      () => _i40.GetCurrentUserFeedbackForRouteUseCase(
        gh<_i566.FeedbackRepository>(),
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
    gh.factory<_i641.RouteSuggestionCubit>(
      () => _i641.RouteSuggestionCubit(
        gh<_i1049.GetAllBusRoutesUseCase>(),
        gh<_i290.BusRealtimeService>(),
        gh<_i753.GetNearbyBusStopsUseCase>(),
        gh<_i167.GetRouteStopsAsBusStopsUseCase>(),
      ),
    );
    gh.factory<_i129.NotificationCubit>(
      () => _i129.NotificationCubit(
        gh<_i171.MonitorStopUseCase>(),
        gh<_i344.ReportVehicleArrivalUseCase>(),
        gh<_i479.GetUserNotificationsUseCase>(),
        gh<_i788.DeleteNotificationUseCase>(),
      ),
    );
    gh.factory<_i655.RouteStopsCubit>(
      () => _i655.RouteStopsCubit(
        gh<_i32.GetRoutesForStopUseCase>(),
        gh<_i422.GetBusRouteByIdUseCase>(),
        gh<_i290.BusRealtimeService>(),
      ),
    );
    gh.factory<_i601.AccountCubit>(
      () => _i601.AccountCubit(
        getCurrentUserUseCase: gh<_i264.GetCurrentUserUseCase>(),
        getUserProfileUseCase: gh<_i909.GetUserProfileUseCase>(),
        updateDisplayNameUseCase: gh<_i346.UpdateDisplayNameUseCase>(),
        updateProfileImageUseCase: gh<_i1067.UpdateProfileImageUseCase>(),
        changePasswordUseCase: gh<_i666.ChangePasswordUseCase>(),
        signOutUseCase: gh<_i284.SignOutUseCase>(),
      ),
    );
    gh.factory<_i839.FeedbackCubit>(
      () => _i839.FeedbackCubit(
        getCurrentUserFeedbackForRoute:
            gh<_i40.GetCurrentUserFeedbackForRouteUseCase>(),
        getOtherFeedbacks:
            gh<_i685.GetFeedbacksByRouteExcludingCurrentUserUseCase>(),
        sendFeedback: gh<_i3.SendFeedbackUseCase>(),
        updateFeedback: gh<_i994.UpdateFeedbackUseCase>(),
      ),
    );
    gh.factory<_i415.OtpCubit>(
      () => _i415.OtpCubit(
        gh<_i725.VerifyEmailOtpUseCase>(),
        gh<_i943.ResendEmailOtpUseCase>(),
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
    gh.factory<_i600.PasswordCubit>(
      () => _i600.PasswordCubit(
        gh<_i405.RequestPasswordResetOtpUseCase>(),
        gh<_i81.ResetPasswordWithOtpUseCase>(),
      ),
    );
    return this;
  }
}

class _$NotificationModule extends _i673.NotificationModule {}

class _$LoggerModule extends _i876.LoggerModule {}

class _$RegisterModule extends _i1057.RegisterModule {}
