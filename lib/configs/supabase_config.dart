import 'package:busmapcantho/configs/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
      url: baseUrl,
      anonKey: apiKey,
      debug: true,
  );
}