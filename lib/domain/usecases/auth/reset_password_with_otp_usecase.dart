import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ResetPasswordWithOtpUseCase {
  final AuthRepository _repo;

  ResetPasswordWithOtpUseCase(this._repo);

  Future<void> call({
    required String email,
    required String otp,
    required String newPassword,
  }) => _repo.resetPasswordWithOtp(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );
}
