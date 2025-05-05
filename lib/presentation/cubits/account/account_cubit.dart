import 'dart:io';

import 'package:busmapcantho/domain/usecases/auth/change_password_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart';
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
  final UpdateDisplayNameUseCase updateDisplayNameUseCase;
  final UpdateProfileImageUseCase updateProfileImageUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final SignOutUseCase signOutUseCase;

  AccountCubit({
    required this.getCurrentUserUseCase,
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
      emit(AccountLoaded(user));
    } catch (e) {
      emit(AccountError('Failed to fetch user info.'));
    }
  }

  Future<void> updateDisplayName(String fullName) async {
    emit(AccountLoading());
    try {
      final user = await updateDisplayNameUseCase(fullName);
      emit(AccountUpdateSuccess('Display name updated successfully!', user));
    } catch (e) {
      emit(AccountError('Failed to update display name.'));
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    emit(AccountLoading());
    try {
      final user = await updateProfileImageUseCase(imageFile);
      emit(AccountUpdateSuccess('Avatar updated successfully!', user));
    } catch (e) {
      emit(AccountError('Failed to update avatar.'));
    }
  }

  Future<void> changePassword(String newPassword) async {
    emit(AccountLoading());
    try {
      await changePasswordUseCase(newPassword);
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AccountUpdateSuccess('Password changed successfully!', user));
      } else {
        emit(AccountError('User not found after password change.'));
      }
    } catch (e) {
      emit(AccountError('Failed to change password.'));
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    emit(AccountLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      final currentState = state;
      if (currentState is AccountLoaded) {
        emit(
          AccountUpdateSuccess(
            enabled ? 'Notifications enabled.' : 'Notifications disabled.',
            currentState.user,
          ),
        );
      } else {
        emit(AccountError('No user loaded.'));
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
