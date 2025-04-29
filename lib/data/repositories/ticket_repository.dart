import '../datasources/ticket_remote_datasource.dart';
import '../model/ticket.dart';

class TicketRepository {
  final TicketRemoteDatasource _ticketRemoteDatasource;

  TicketRepository([TicketRemoteDatasource? ticketRemoteDatasource])
    : _ticketRemoteDatasource =
          ticketRemoteDatasource ?? TicketRemoteDatasource();

  Future<void> addTicket(Ticket ticket) async {
    await _ticketRemoteDatasource.addTicket(ticket);
  }

  Future<List<Ticket>> getUserTickets(String userId) async {
    return await _ticketRemoteDatasource.getUserTickets(userId);
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _ticketRemoteDatasource.updateTicketStatus(ticketId, status);
  }
}
