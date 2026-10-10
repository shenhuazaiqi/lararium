-- ============================================================
-- 协作邀请 + 照片存储（阶段 3 协作与媒体）
-- ============================================================

-- 树所有者生成邀请码（8 位大写，默认编辑者权限）
create or replace function public.create_invite(tid uuid, role text default 'editor')
returns text
language plpgsql security definer set search_path = public as $$
declare
  code text;
begin
  if not public.is_tree_member(tid, 'owner') then
    raise exception 'NOT_OWNER';
  end if;
  if role not in ('editor','viewer') then
    raise exception 'BAD_ROLE';
  end if;
  loop
    code := upper(substr(translate(md5(random()::text || clock_timestamp()::text), 'abcdef', 'ABCDEF'), 1, 8));
    exit when not exists (select 1 from public.invites where invites.code = code);
  end loop;
  insert into public.invites (tree_id, code, role, created_by)
  values (tid, code, role, auth.uid());
  return code;
end $$;

-- 兑换邀请码：校验有效性 → 当前用户加入树 → 返回树信息
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
   where upper(invites.code) = upper(code)
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

grant execute on function public.create_invite(uuid, text) to authenticated;
grant execute on function public.redeem_invite(text) to authenticated;

-- ---------- 照片存储桶（私密：仅树成员可读写） ----------
insert into storage.buckets (id, name, public)
values ('person-photos', 'person-photos', false)
on conflict (id) do nothing;

-- 路径约定：tree_<uuid>/person_<personId>.jpg
create or replace function public.path_tree_id(path text)
returns uuid
language plpgsql immutable as $$
declare prefix text;
begin
  prefix := split_part(path, '/', 1);
  if prefix like 'tree\_%' escape '\' and length(prefix) = 41 then
    return substr(prefix, 6)::uuid;
  end if;
  return null;
exception when others then
  return null;
end $$;

create policy "photos read: tree members" on storage.objects
  for select using (
    bucket_id = 'person-photos'
    and public.is_tree_member(public.path_tree_id(name))
  );
create policy "photos write: tree editors" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'person-photos'
    and public.is_tree_member(public.path_tree_id(name), 'editor')
  );
create policy "photos delete: tree editors" on storage.objects
  for delete using (
    bucket_id = 'person-photos'
    and public.is_tree_member(public.path_tree_id(name), 'editor')
  );
