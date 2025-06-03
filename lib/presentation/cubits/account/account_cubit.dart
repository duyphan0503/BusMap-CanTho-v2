import 'dart:io';

import 'package:busmapcantho/domain/usecases/auth/change_password_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/get_user_profile_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_out_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/update_display_name_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/usecases/auth/update_profile_image_usecase.dart';

part 'account_state.dart';

@injectable
class AccountCubit extends Cubit<AccountState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateDisplayNameUseCase updateDisplayNameUseCase;
  final UpdateProfileImageUseCase updateProfileImageUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final SignOutUseCase signOutUseCase;

  AccountCubit({
    required this.getCurrentUserUseCase,
    required this.getUserProfileUseCase,
    required this.updateDisplayNameUseCase,
    required this.updateProfileImageUseCase,
    required this.changePasswordUseCase,
    required this.signOutUseCase,
  }) : super(AccountInitial());

  Future<void> getCurrentUser() async {
    emit(AccountLoading());
    try {
      final user = await getCurrentUserUseCase();
      if (user == null) {
        emit(AccountError('No user is logged in.'));
        return;
      }

      final userProfile = await getUserProfileUseCase();

      emit(AccountLoaded(user, userProfile));
    } catch (e) {
      emit(AccountError('Failed to fetch user info.'));
    }
  }

  Future<void> updateDisplayName(String fullName) async {
    emit(AccountLoading());
    try {
      final user = await updateDisplayNameUseCase(fullName);

      final userProfile = await getUserProfileUseCase();

      emit(
        AccountUpdateSuccess(
          'Display name updated successfully!',
          user,
          userProfile,
        ),
      );
    } catch (e) {
      emit(AccountError('Failed to update display name.'));
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    emit(AccountLoading());
    try {
      final user = await updateProfileImageUseCase(imageFile);

      final userProfile = await getUserProfileUseCase();

      emit(
        AccountUpdateSuccess('Avatar updated successfully!', user, userProfile),
      );
    } catch (e) {
      emit(AccountError('Failed to update avatar.'));
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(AccountLoading());
    try {
      await changePasswordUseCase(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      final user = await getCurrentUserUseCase();
      if (user != null) {
        final userProfile = await getUserProfileUseCase();
        emit(
          AccountUpdateSuccess(
            'Password changed successfully!',
            user,
            userProfile,
          ),
        );
      } else {
        emit(AccountError('User not found after password change.'));
      }
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    // Store the previous state to restore it after toggling
    final previousState = state;

    emit(AccountLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);

      final message =
          enabled ? 'Notifications enabled.' : 'Notifications disabled.';

      if (previousState is AccountLoaded) {
        emit(
          AccountUpdateSuccess(
            message,
            previousState.user,
            previousState.userProfile,
          ),
        );
      } else if (previousState is AccountUpdateSuccess) {
        emit(
          AccountUpdateSuccess(
            message,
            previousState.user,
            previousState.userProfile,
          ),
        );
      } else {
        emit(previousState);
      }
    } catch (e) {
      emit(AccountError('Failed to update notification preferences.'));
    }
  }

  Future<void> signOut() async {
    try {
      await signOutUseCase();
      emit(AccountSignedOut());
    } catch (e) {
      emit(AccountError('Failed to sign out.'));
    }
  }
}
