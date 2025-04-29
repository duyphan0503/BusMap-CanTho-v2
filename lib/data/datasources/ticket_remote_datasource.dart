import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/ticket.dart';

class TicketRemoteDatasource {
  final SupabaseClient _client;

  TicketRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<Ticket>> getUserTickets(String userId) async {
    final response = await _client
        .from('tickets')
        .select()
        .eq('user_id', userId)
        .order('purchased_at', ascending: false);
    return (response as List).map((e) => Ticket.fromJson(e)).toList();
  }

  Future<void> addTicket(Ticket ticket) async {
    await _client.from('tickets').insert(ticket.toJson());
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _client.from('tickets').update({'status': status}).eq('id', ticketId);
  }
}