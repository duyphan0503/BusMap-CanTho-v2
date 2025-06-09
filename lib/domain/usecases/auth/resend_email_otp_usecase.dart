import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@injectable
class ResendEmailOtpUseCase {
  final AuthRepository _authRepository;

  ResendEmailOtpUseCase(this._authRepository);

  Future<void> call({required String email, bool isReset = false}) async {
    return _authRepository.resendEmailOtp(email: email, isReset: isReset);
  }
}
