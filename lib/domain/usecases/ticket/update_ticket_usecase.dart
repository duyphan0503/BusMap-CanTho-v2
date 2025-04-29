import '../../../data/repositories/ticket_repository.dart';

class UpdateTicketStatusUseCase {
  final TicketRepository _repo;
  UpdateTicketStatusUseCase(this._repo);

  Future<void> call(String ticketId, String status) =>
      _repo.updateTicketStatus(ticketId, status);
}