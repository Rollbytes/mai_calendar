import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 服務類，提供與 Supabase 後端的通信功能
class SupabaseService {
  late final SupabaseClient _client;

  // 單例模式
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// 初始化 Supabase 客戶端
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    _client = Supabase.instance.client;
  }

  /// 獲取 Supabase 客戶端實例
  SupabaseClient get client => _client;

  /// 用戶認證相關方法
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 數據相關方法
  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await _client.from('events').select().order('created_at', ascending: false);

    return response;
  }

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    await _client.from('events').insert(eventData);
  }

  Future<void> updateEvent(String id, Map<String, dynamic> eventData) async {
    await _client.from('events').update(eventData).eq('id', id);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }
}
