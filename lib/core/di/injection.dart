import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:busmapcantho/services/map_caching_service.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
void configureDependencies() {
  getIt.init();

  // other registrations via injectable
}
