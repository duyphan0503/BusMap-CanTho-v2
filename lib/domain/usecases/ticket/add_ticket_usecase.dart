import '../../../data/model/ticket.dart';
import '../../../data/repositories/ticket_repository.dart';

class AddTicketUseCase {
  final TicketRepository _repo;
  AddTicketUseCase(this._repo);

  Future<void> call(Ticket ticket) => _repo.addTicket(ticket);
}