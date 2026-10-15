-- 恢复 Carter 树 owner 角色（redeem 降级 bug 受害者）
update public.tree_members set role = 'owner'
where tree_id = 'd9c41ac9-6994-4bff-8e77-80708c2453e4'
  and user_id = '3706ef3b-9208-4cd1-8c1b-52cad8eaa456';

-- 修复 redeem_invite 的角色降级 bug：
-- 已是树成员的用户兑换同一树的邀请时，保留其现有角色（不降级）
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
  on conflict (tree_id, user_id) do nothing; -- 已是成员：保留现有角色（防 owner/editor 降级）
  update public.invites set used_count = used_count + 1 where id = inv.id;
  return json_build_object('tree_id', t.id, 'name', t.name, 'role', inv.role);
end $$;
