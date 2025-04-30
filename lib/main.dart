import 'package:busmapcantho/configs/supabase_config.dart';
import 'package:busmapcantho/data/repositories/auth_repository.dart';
import 'package:busmapcantho/domain/usecases/auth/request_password_reset_otp_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/reset_password_with_otp_usecase.dart';
import 'package:busmapcantho/presentation/cubits/account/account_cubit.dart';
import 'package:busmapcantho/presentation/cubits/auth/auth_cubit.dart';
import 'package:busmapcantho/presentation/cubits/otp/otp_cubit.dart';
import 'package:busmapcantho/presentation/cubits/password/password_cubit.dart';
import 'package:busmapcantho/providers/localization_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'configs/config_channel.dart';
import 'configs/secure_config.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'domain/usecases/auth/change_password_usecase.dart';
import 'domain/usecases/auth/get_current_user_usecase.dart';
import 'domain/usecases/auth/google_sign_in_native_usecase.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/auth/update_display_name_usecase.dart';
import 'domain/usecases/auth/update_profile_image_usecase.dart';
import 'domain/usecases/auth/verify_email_otp_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initSupabase();
  await EasyLocalization.ensureInitialized();
  await SecureConfig.initialize();
  await ConfigChannel.init();

  final prefs = await SharedPreferences.getInstance();
  final saveLocale = prefs.getString('locale') ?? 'en';

  final authDatasource = AuthRemoteDatasource();
  authDatasource.initAuthListener();
  final authRepository = AuthRepository(authDatasource);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      startLocale: Locale(saveLocale),
      child: MultiProvider(
        providers: [
          BlocProvider(
            create:
                (_) => AuthCubit(
                  SignUpUseCase(authRepository),
                  SignInUseCase(authRepository),
                  GoogleSignInNativeUseCase(authRepository),
                ),
          ),
          BlocProvider(
            create: (_) => OtpCubit(VerifyEmailOtpUseCase(authRepository)),
          ),
          BlocProvider(
            create:
                (_) => PasswordCubit(
                  RequestPasswordResetOtpUseCase(authRepository),
                  ResetPasswordWithOtpUseCase(authRepository),
                ),
          ),
          BlocProvider(
            create:
                (_) => AccountCubit(
                  getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
                  updateDisplayNameUseCase: UpdateDisplayNameUseCase(
                    authRepository,
                  ),
                  updateProfileImageUseCase: UpdateProfileImageUseCase(
                    authRepository,
                  ),
                  changePasswordUseCase: ChangePasswordUseCase(authRepository),
                  signOutUseCase: SignOutUseCase(authRepository),
                ),
          ),
          ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ],
        child: const BusMapCanThoApp(),
      ),
    ),
  );
}
