import 'package:injectable/injectable.dart';

import '../datasources/agency_remote_datasource.dart';
import '../model/agency.dart';

@lazySingleton
class AgencyRepository {
  final AgencyRemoteDatasource _remoteDatasource;

  AgencyRepository(this._remoteDatasource);

  // Get all agencies
  Future<List<Agency>> getAgencies() {
    return _remoteDatasource.getAgencies();
  }

  // Get agency by ID
  Future<Agency> getAgencyById(String id) {
    return _remoteDatasource.getAgencyById(id);
  }
}
