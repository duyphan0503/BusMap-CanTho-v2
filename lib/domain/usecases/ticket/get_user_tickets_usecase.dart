import '../../../data/model/ticket.dart';
import '../../../data/repositories/ticket_repository.dart';

class GetUserTicketsUseCase {
  final TicketRepository _repo;
  GetUserTicketsUseCase(this._repo);

  Future<List<Ticket>> call() => _repo.getUserTickets();
}