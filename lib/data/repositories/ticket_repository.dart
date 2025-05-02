import 'package:injectable/injectable.dart';

import '../datasources/ticket_remote_datasource.dart';
import '../model/ticket.dart';

@lazySingleton
class TicketRepository {
  final TicketRemoteDatasource _ticketRemoteDatasource;

  TicketRepository(this._ticketRemoteDatasource);

  // Get tickets for the current authenticated user
  Future<List<Ticket>> getUserTickets() {
    return _ticketRemoteDatasource.getTickets();
  }

  // Purchase a new ticket
  Future<Ticket> purchaseTicket({
    required String routeId,
    required String fromStopId,
    required String toStopId,
    required double price,
  }) {
    return _ticketRemoteDatasource.purchaseTicket(
      routeId: routeId,
      fromStopId: fromStopId,
      toStopId: toStopId,
      price: price,
    );
  }

  // Mark a ticket as used
  Future<void> updateTicketStatus(String ticketId, String status) {
    if (status != 'used') {
      throw ArgumentError('Only "used" status is supported');
    }
    return _ticketRemoteDatasource.useTicket(ticketId);
  }

  // Deprecated method - use purchaseTicket instead
  Future<void> addTicket(Ticket ticket) {
    throw UnimplementedError('Use purchaseTicket instead');
  }

  // Deprecated method - use getUserTickets instead
  Future<List<Ticket>> getUserTicketsByUserId(String userId) {
    return getUserTickets();
  }
}
