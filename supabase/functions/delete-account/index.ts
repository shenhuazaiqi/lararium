// Supabase Edge Function: delete-account
// 账号删除（Play 合规：应用内删除入口 + GDPR）。需要用户 Authorization JWT。
// 行为：删除用户拥有的全部树（FK 级联清人物/家庭/留言）→ 移除成员记录 → 删除 auth 用户。
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }
  const authHeader = req.headers.get('Authorization') ?? '';
  if (!authHeader.startsWith('Bearer ')) {
    return new Response('Unauthorized', { status: 401 });
  }
  const jwt = authHeader.slice(7);

  // 用用户自己的 JWT 确认身份
  const userClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: userData, error: userErr } = await userClient.auth.getUser(jwt);
  if (userErr || !userData?.user) {
    return new Response('Unauthorized', { status: 401 });
  }
  const uid = userData.user.id;

  // service role 执行清洗
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  // 1) 用户拥有的树（FK 级联清 persons → memorial_*；families/children/messages 按 tree_id 级联）
  const { data: owned, error: treeErr } = await admin
    .from('trees')
    .select('id')
    .eq('owner_id', uid);
  if (treeErr) {
    return new Response(`tree query failed: ${treeErr.message}`, { status: 500 });
  }
  for (const t of owned ?? []) {
    const { error: delErr } = await admin.from('trees').delete().eq('id', t.id);
    if (delErr) {
      return new Response(`tree delete failed: ${delErr.message}`, { status: 500 });
    }
  }
  // 2) 作为成员参与的他人树：移除成员记录（树本身不动）
  await admin.from('tree_members').delete().eq('user_id', uid);

  // 3) 删除 auth 用户（service role）
  const { error: delUserErr } = await admin.auth.admin.deleteUser(uid);
  if (delUserErr) {
    return new Response(`user delete failed: ${delUserErr.message}`, { status: 500 });
  }

  return new Response(JSON.stringify({ ok: true }), {
    headers: { 'content-type': 'application/json' },
  });
});
