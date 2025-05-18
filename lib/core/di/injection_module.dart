import 'package:injectable/injectable.dart';
import 'package:busmapcantho/services/map_caching_service.dart';

@module
abstract class MapCachingModule {
  @lazySingleton
  MapCachingService get mapCachingService;
}
