import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => SupabaseConfig.client;

  static String? get currentUserId => SupabaseConfig.currentUserId;
  static User? get currentUser => SupabaseConfig.currentUser;
}
