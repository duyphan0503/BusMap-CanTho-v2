import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/ticket.dart';

@lazySingleton
class TicketRemoteDatasource {
  final SupabaseClient _client;

  TicketRemoteDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<Ticket>> getTickets() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to view tickets');
      }

      final response = await _client
          .from('tickets')
          .select('*, route:routes(*), from_stop:stops(*), to_stop:stops(*)')
          .eq('user_id', user.id)
          .order('purchased_at', ascending: false);
      
      return response.map((data) => Ticket.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load tickets: $e');
    }
  }

  Future<Ticket> purchaseTicket({
    required String routeId,
    required String fromStopId,
    required String toStopId,
    required double price,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to purchase a ticket');
      }

      final ticketData = {
        'user_id': user.id,
        'route_id': routeId,
        'from_stop_id': fromStopId,
        'to_stop_id': toStopId,
        'price': price,
        'status': 'unused',
      };

      final response = await _client
          .from('tickets')
          .insert(ticketData)
          .select('*, route:routes(*), from_stop:stops(*), to_stop:stops(*)')
          .single();
      
      return Ticket.fromJson(response);
    } catch (e) {
      throw Exception('Failed to purchase ticket: $e');
    }
  }

  Future<void> useTicket(String ticketId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to use a ticket');
      }

      await _client
          .from('tickets')
          .update({'status': 'used'})
          .eq('id', ticketId)
          .eq('user_id', user.id); // Safety check
    } catch (e) {
      throw Exception('Failed to use ticket: $e');
    }
  }
}
