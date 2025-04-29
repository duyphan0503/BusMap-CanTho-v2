import 'package:busmapcantho/data/repositories/auth_repository.dart';

class RequestPasswordResetOtpUseCase {
  final AuthRepository _repo;

  RequestPasswordResetOtpUseCase(this._repo);

  Future<void> call(String email) => _repo.requestPasswordResetOtp(email: email);
}