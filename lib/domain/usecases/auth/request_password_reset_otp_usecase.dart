import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RequestPasswordResetOtpUseCase {
  final AuthRepository _repo;

  RequestPasswordResetOtpUseCase(this._repo);

  Future<void> call(String email) =>
      _repo.requestPasswordResetOtp(email: email);
}