// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:busmapcantho/core/di/register_module.dart' as _i609;
import 'package:busmapcantho/data/datasources/auth_remote_datasource.dart'
    as _i1019;
import 'package:busmapcantho/data/repositories/auth_repository_impl.dart'
    as _i736;
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
import 'package:busmapcantho/presentation/cubits/account/account_cubit.dart'
    as _i601;
import 'package:busmapcantho/presentation/cubits/auth/auth_cubit.dart' as _i122;
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
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i1019.AuthRemoteDatasource>(
      () => _i1019.AuthRemoteDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i556.AuthRepository>(
      () => _i736.AuthRepositoryImpl(gh<_i1019.AuthRemoteDatasource>()),
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
    gh.factory<_i601.AccountCubit>(
      () => _i601.AccountCubit(
        getCurrentUserUseCase: gh<_i264.GetCurrentUserUseCase>(),
        updateDisplayNameUseCase: gh<_i346.UpdateDisplayNameUseCase>(),
        updateProfileImageUseCase: gh<_i1067.UpdateProfileImageUseCase>(),
        changePasswordUseCase: gh<_i666.ChangePasswordUseCase>(),
        signOutUseCase: gh<_i284.SignOutUseCase>(),
      ),
    );
    gh.factory<_i122.AuthCubit>(
      () => _i122.AuthCubit(
        gh<_i421.SignUpUseCase>(),
        gh<_i995.SignInUseCase>(),
        gh<_i686.GoogleSignInNativeUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i609.RegisterModule {}
