-- 修复邀请 RPC 的 PL/pgSQL 变量与表列同名歧义（Postgres 14+ 报
-- "column reference code is ambiguous"，导致生成/兑换邀请码全部失败）。
-- 对外参数签名不变（App 按 {'tid','role'} / {'code'} 调用）。
-- redeem_invite 内部变量引用用函数名限定（redeem_invite.code）。

create or replace function public.redeem_invite(code text)
returns json
language plpgsql security definer set search_path = public as $$
declare
  inv public.invites%rowtype;
  uid uuid := auth.uid();
  t public.trees%rowtype;
begin
  if uid is null then
    raise exception 'NOT_SIGNED_IN';
  end if;
  select * into inv from public.invites
   where upper(invites.code) = upper(redeem_invite.code)
   for update;
  if not found then
    raise exception 'INVITE_NOT_FOUND';
  end if;
  if inv.expires_at is not null and inv.expires_at < now() then
    raise exception 'INVITE_EXPIRED';
  end if;
  if inv.max_uses is not null and inv.used_count >= inv.max_uses then
    raise exception 'INVITE_EXHAUSTED';
  end if;
  select * into t from public.trees where id = inv.tree_id and deleted_at is null;
  if not found then
    raise exception 'TREE_GONE';
  end if;
  insert into public.tree_members (tree_id, user_id, role, invited_by)
  values (inv.tree_id, uid, inv.role, inv.created_by)
  on conflict (tree_id, user_id) do update set role = excluded.role;
  update public.invites set used_count = used_count + 1 where id = inv.id;
  return json_build_object('tree_id', t.id, 'name', t.name, 'role', inv.role);
end $$;

grant execute on function public.redeem_invite(text) to authenticated;

-- create_invite 同类修复（内部变量改名 v_code，对外签名不变）
create or replace function public.create_invite(tid uuid, role text default 'editor')
returns text
language plpgsql security definer set search_path = public as $$
declare
  v_code text;
begin
  if not public.is_tree_member(tid, 'owner') then
    raise exception 'NOT_OWNER';
  end if;
  if role not in ('editor','viewer') then
    raise exception 'BAD_ROLE';
  end if;
  loop
    v_code := upper(substr(translate(md5(random()::text || clock_timestamp()::text), 'abcdef', 'ABCDEF'), 1, 8));
    exit when not exists (select 1 from public.invites where invites.code = v_code);
  end loop;
  insert into public.invites (tree_id, code, role, created_by)
  values (tid, v_code, role, auth.uid());
  return v_code;
end $$;

grant execute on function public.create_invite(uuid, text) to authenticated;
