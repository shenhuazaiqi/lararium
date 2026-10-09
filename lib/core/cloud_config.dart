/// Supabase 云配置 —— 规划文档 6.1：本地 SQLite 是唯一数据源，云只是副本。
///
/// anon / publishable key 是设计上公开的客户端密钥（受 RLS 保护），
/// 可以打进客户端；service_role / secret 绝不能出现在客户端代码或仓库里。
///
/// 覆盖方式：flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class CloudConfig {
  CloudConfig._();

  static const String projectRef = 'sdxhduusacwnimcrkkqv';

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sdxhduusacwnimcrkkqv.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkeGhkdXVzYWN3bmltY3Jra3F2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE1NDU2ODMsImV4cCI6MjEwNzEyMTY4M30.V39Gt2UbFcwo76y2Odda5MQ_Vg2WpopGB_0H3nfZ6CQ',
  );
}
