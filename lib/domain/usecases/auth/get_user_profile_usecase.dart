import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@injectable
class GetUserProfileUseCase {
  final AuthRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Map<String, dynamic>?> call() async {
    return await _repository.getUserProfile();
  }
}
