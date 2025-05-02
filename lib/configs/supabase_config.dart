import 'package:busmapcantho/configs/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/local/secure_session_storage.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: baseUrl,
    anonKey: apiKey,
    debug: true,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      authFlowType: AuthFlowType.pkce,
    ).copyWith(localStorage: SecureSessionStorage()),
  );
}
