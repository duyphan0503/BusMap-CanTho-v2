import '../../../data/repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  final AuthRepository _repo;

  VerifyEmailOtpUseCase(this._repo);

  Future<void> call({required String email, required String otp}) =>
      _repo.verifyEmailOtp(email: email, otp: otp);
}
