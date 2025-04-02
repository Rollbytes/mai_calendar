/// 環境配置
class EnvConfig {
  // 如果您希望使用 Supabase 雲端服務，請替換為您在 supabase.com 創建的項目 URL
  // 1. 註冊 supabase.com
  // 2. 創建新項目
  // 3. 從項目設置中獲取 URL 和 anon key
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321', // 本地 Supabase 的 URL
  );

  // 替換為您的 Supabase 項目 anon key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0', // 本地 Supabase 的 anon key
  );
}
