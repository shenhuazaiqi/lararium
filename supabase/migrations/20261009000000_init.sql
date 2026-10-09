-- ============================================================
-- Lararium · 初始 schema（规划文档 6.3 + 6.7）
-- 本地 SQLite 为唯一真源；此 Postgres schema 为云副本 + 协作/缅怀服务端。
-- 兼容 GEDCOM 5.5.1 / 7 的模型字段（gedcom_id 等）。
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- 家谱 ----------
create table public.trees (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  owner_id uuid not null references auth.users(id) on delete cascade,
  cover_person_id uuid,
  visibility text not null default 'private', -- private | link | public
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- 树成员与权限：owner | editor | viewer
create table public.tree_members (
  tree_id uuid not null references public.trees(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'viewer',
  invited_by uuid references auth.users(id),
  joined_at timestamptz not null default now(),
  primary key (tree_id, user_id)
);

-- ---------- 人物 ----------
create table public.persons (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees(id) on delete cascade,
  gedcom_id text,
  given_name text not null default '',
  surname text not null default '',
  nickname text,
  gender text not null default 'unknown', -- male | female | other | unknown
  birth_date date,
  birth_date_precision text not null default 'day', -- day|month|year|approx|range
  birth_place text,
  death_date date,
  death_date_precision text not null default 'day',
  death_place text,
  burial_place text,
  is_living boolean not null default true,
  occupation text,
  note text,
  avatar_media_id uuid,
  created_by uuid references auth.users(id),
  client_updated_at timestamptz not null default now(),
  revision int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index idx_persons_tree on public.persons(tree_id) where deleted_at is null;
create index idx_persons_updated on public.persons(tree_id, updated_at);

-- ---------- 核心家庭（GEDCOM FAM） ----------
create table public.families (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees(id) on delete cascade,
  gedcom_id text,
  partner1_id uuid references public.persons(id) on delete set null,
  partner2_id uuid references public.persons(id) on delete set null,
  relation_type text not null default 'married', -- married|unmarried|divorced|partner
  marriage_date date,
  marriage_place text,
  divorce_date date,
  sort_order int not null default 0,
  client_updated_at timestamptz not null default now(),
  revision int not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index idx_families_tree on public.families(tree_id) where deleted_at is null;

-- 子女归属（一个孩子可属于多个家庭：亲生 + 收养）
create table public.family_children (
  family_id uuid not null references public.families(id) on delete cascade,
  person_id uuid not null references public.persons(id) on delete cascade,
  tree_id uuid not null references public.trees(id) on delete cascade,
  sort_order int not null default 0,
  pedigree text not null default 'birth', -- birth|adopted|foster|step
  primary key (family_id, person_id)
);
create index idx_children_person on public.family_children(person_id);

-- ---------- 通用事件（对齐 GEDCOM 事件模型） ----------
create table public.events (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees(id) on delete cascade,
  person_id uuid references public.persons(id) on delete cascade,
  family_id uuid references public.families(id) on delete cascade,
  type text not null, -- BIRT|DEAT|BURI|CHR|GRAD|OCCU|RESI|IMMI|custom
  date_text text,
  date_from date,
  date_to date,
  date_precision text,
  place_text text,
  latitude double precision,
  longitude double precision,
  description text,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index idx_events_person on public.events(person_id) where deleted_at is null;

-- ---------- 媒体 ----------
create table public.media (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees(id) on delete cascade,
  person_id uuid references public.persons(id) on delete set null,
  family_id uuid references public.families(id) on delete set null,
  event_id uuid references public.events(id) on delete set null,
  kind text not null default 'photo', -- photo|document|audio|video
  storage_path text,
  local_path text,
  mime text,
  width int,
  height int,
  bytes bigint,
  caption text,
  is_primary boolean not null default false,
  upload_state text not null default 'pending', -- pending|uploading|done|failed
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ---------- 邀请 ----------
create table public.invites (
  id uuid primary key default gen_random_uuid(),
  tree_id uuid not null references public.trees(id) on delete cascade,
  code text not null unique,
  role text not null default 'viewer',
  expires_at timestamptz,
  max_uses int,
  used_count int not null default 0,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- ---------- 缅怀纪念（5.4 / 6.7） ----------
create table public.memorial_profiles (
  person_id uuid primary key references public.persons(id) on delete cascade,
  tree_id uuid not null references public.trees(id) on delete cascade,
  is_enabled boolean not null default true,
  theme text, -- western|east_asian|latin|jewish|hindu|islamic|secular|null=未选择
  theme_is_auto boolean not null default true,
  epitaph text,
  cover_media_id uuid,
  allow_messages boolean not null default true,
  allow_public_link boolean not null default false,
  allow_anonymous boolean not null default true,
  flower_count int not null default 0,
  candle_count int not null default 0,
  incense_count int not null default 0,
  prayer_count int not null default 0,
  message_count int not null default 0,
  last_memorial_at timestamptz,
  updated_at timestamptz not null default now()
);
create index idx_memorial_tree on public.memorial_profiles(tree_id);

create table public.memorial_acts (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references public.persons(id) on delete cascade,
  tree_id uuid not null references public.trees(id) on delete cascade,
  actor_user_id uuid references auth.users(id),
  actor_name text,
  is_anonymous boolean not null default false,
  kind text not null, -- flower|candle|incense|prayer|stone|diya|wreath|lantern
  item_code text,
  quantity int not null default 1,
  source text not null default 'app', -- app|web
  client_updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index idx_acts_person_time on public.memorial_acts(person_id, created_at desc);

create table public.memorial_messages (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references public.persons(id) on delete cascade,
  tree_id uuid not null references public.trees(id) on delete cascade,
  author_user_id uuid references auth.users(id),
  author_name text not null,
  is_anonymous boolean not null default false,
  body text not null,
  lang text,
  attachment_media_id uuid,
  like_count int not null default 0,
  status text not null default 'visible', -- visible|hidden|reported|deleted
  is_pinned boolean not null default false,
  client_updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index idx_messages_person on public.memorial_messages(person_id, created_at desc);

create table public.memorial_message_likes (
  message_id uuid not null references public.memorial_messages(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (message_id, user_id)
);

create table public.memorial_reports (
  id uuid primary key default gen_random_uuid(),
  target_type text not null, -- message|profile
  target_id uuid not null,
  reason text not null,
  reporter_user_id uuid references auth.users(id),
  status text not null default 'pending',
  handled_at timestamptz,
  created_at timestamptz not null default now()
);

-- ============================================================
-- 触发器：更新时间 / 计数冗余 / 在世人强制关闭缅怀
-- ============================================================

-- updated_at 自动维护
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_trees_touch on public.trees;
create trigger trg_trees_touch before update on public.trees
  for each row execute function public.touch_updated_at();
drop trigger if exists trg_persons_touch on public.persons;
create trigger trg_persons_touch before update on public.persons
  for each row execute function public.touch_updated_at();

-- 缅怀计数冗余（读取 O(1)，规划文档 6.7）
create or replace function public.bump_memorial_count()
returns trigger language plpgsql as $$
declare
  col text;
begin
  col := case new.kind
    when 'flower' then 'flower_count'
    when 'candle' then 'candle_count'
    when 'incense' then 'incense_count'
    when 'prayer' then 'prayer_count'
    else null end;
  if col is not null then
    execute format(
      'update public.memorial_profiles set %I = %I + %s, last_memorial_at = now()
       where person_id = %L', col, col, coalesce(new.quantity, 1), new.person_id);
  else
    update public.memorial_profiles set last_memorial_at = now()
      where person_id = new.person_id;
  end if;
  return new;
end $$;

drop trigger if exists trg_act_count on public.memorial_acts;
create trigger trg_act_count after insert on public.memorial_acts
  for each row execute function public.bump_memorial_count();

-- 留言计数
create or replace function public.bump_message_count()
returns trigger language plpgsql as $$
begin
  update public.memorial_profiles set message_count = message_count + 1
    where person_id = new.person_id;
  return new;
end $$;

drop trigger if exists trg_msg_count on public.memorial_messages;
create trigger trg_msg_count after insert on public.memorial_messages
  for each row execute function public.bump_message_count();

-- 在世人物强制隐藏缅怀（5.4.5 合规：对在世人物误操作防护）
create or replace function public.sync_memorial_profile()
returns trigger language plpgsql as $$
begin
  if new.is_living then
    insert into public.memorial_profiles(person_id, tree_id, is_enabled)
    values (new.id, new.tree_id, false)
    on conflict (person_id) do update set is_enabled = false;
  else
    insert into public.memorial_profiles(person_id, tree_id)
    values (new.id, new.tree_id)
    on conflict (person_id) do nothing;
  end if;
  return new;
end $$;

drop trigger if exists trg_person_memorial on public.persons;
create trigger trg_person_memorial after insert or update of is_living on public.persons
  for each row execute function public.sync_memorial_profile();

-- ============================================================
-- RLS：所有表开启，经 tree_members 判权；
-- 用 SECURITY DEFINER 函数避免 RLS 递归（规划文档 6.3）
-- ============================================================

create or replace function public.is_tree_member(tid uuid, min_role text default 'viewer')
returns boolean language sql security definer set search_path = public stable as $$
  select exists (
    select 1 from public.tree_members m
    where m.tree_id = tid
      and m.user_id = auth.uid()
      and case min_role
            when 'owner' then m.role = 'owner'
            when 'editor' then m.role in ('owner','editor')
            else true
          end
  )
$$;

alter table public.trees enable row level security;
alter table public.tree_members enable row level security;
alter table public.persons enable row level security;
alter table public.families enable row level security;
alter table public.family_children enable row level security;
alter table public.events enable row level security;
alter table public.media enable row level security;
alter table public.invites enable row level security;
alter table public.memorial_profiles enable row level security;
alter table public.memorial_acts enable row level security;
alter table public.memorial_messages enable row level security;
alter table public.memorial_message_likes enable row level security;
alter table public.memorial_reports enable row level security;

-- trees
create policy trees_select on public.trees
  for select using (public.is_tree_member(id));
create policy trees_write on public.trees
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- tree_members
create policy members_select on public.tree_members
  for select using (public.is_tree_member(tree_id));
create policy members_manage on public.tree_members
  for all using (public.is_tree_member(tree_id, 'owner'))
  with check (public.is_tree_member(tree_id, 'owner'));
create policy members_join on public.tree_members
  for insert with check (user_id = auth.uid());

-- 内容表通用模式：成员可读，editor+ 可写
create policy persons_select on public.persons
  for select using (public.is_tree_member(tree_id));
create policy persons_write on public.persons
  for all using (public.is_tree_member(tree_id, 'editor'))
  with check (public.is_tree_member(tree_id, 'editor'));

create policy families_select on public.families
  for select using (public.is_tree_member(tree_id));
create policy families_write on public.families
  for all using (public.is_tree_member(tree_id, 'editor'))
  with check (public.is_tree_member(tree_id, 'editor'));

create policy children_select on public.family_children
  for select using (public.is_tree_member(tree_id));
create policy children_write on public.family_children
  for all using (public.is_tree_member(tree_id, 'editor'))
  with check (public.is_tree_member(tree_id, 'editor'));

create policy events_select on public.events
  for select using (public.is_tree_member(tree_id));
create policy events_write on public.events
  for all using (public.is_tree_member(tree_id, 'editor'))
  with check (public.is_tree_member(tree_id, 'editor'));

create policy media_select on public.media
  for select using (public.is_tree_member(tree_id));
create policy media_write on public.media
  for all using (public.is_tree_member(tree_id, 'editor'))
  with check (public.is_tree_member(tree_id, 'editor'));

create policy invites_select on public.invites
  for select using (public.is_tree_member(tree_id));
create policy invites_write on public.invites
  for all using (public.is_tree_member(tree_id, 'owner'))
  with check (public.is_tree_member(tree_id, 'owner'));

-- 缅怀：树成员可读；editor+ 可写动作；留言作者可写自己的
create policy profiles_select on public.memorial_profiles
  for select using (public.is_tree_member(tree_id));
create policy profiles_write on public.memorial_profiles
  for all using (public.is_tree_member(tree_id, 'editor'))
  with check (public.is_tree_member(tree_id, 'editor'));

create policy acts_select on public.memorial_acts
  for select using (public.is_tree_member(tree_id));
create policy acts_insert on public.memorial_acts
  for insert with check (public.is_tree_member(tree_id) and actor_user_id = auth.uid());

create policy messages_select on public.memorial_messages
  for select using (public.is_tree_member(tree_id));
create policy messages_insert on public.memorial_messages
  for insert with check (public.is_tree_member(tree_id) and author_user_id = auth.uid());
create policy messages_update on public.memorial_messages
  for update using (author_user_id = auth.uid() or public.is_tree_member(tree_id, 'editor'));

create policy likes_all on public.memorial_message_likes
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy reports_insert on public.memorial_reports
  for insert with check (reporter_user_id = auth.uid());
create policy reports_select on public.memorial_reports
  for select using (reporter_user_id = auth.uid());

-- ---------- 免费额度限额（5.4.4：各 1 次/天，忌日 +1；服务端可配） ----------
create or replace function public.check_act_quota()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  daily_limit int := coalesce(
    current_setting('app.memorial_daily_limit', true)::int, 1);
  used int;
  is_anniv boolean;
begin
  select count(*) into used
    from public.memorial_acts
   where actor_user_id = new.actor_user_id
     and kind = new.kind
     and created_at >= date_trunc('day', now());

  select (p.death_date is not null
    and date_trunc('day', p.death_date) = date_trunc('day', now()))::boolean
    into is_anniv
    from public.persons p where p.id = new.person_id;

  if used >= daily_limit + (case when is_anniv then 1 else 0 end) then
    raise exception 'DAILY_QUOTA_EXCEEDED';
  end if;
  return new;
end $$;

drop trigger if exists trg_act_quota on public.memorial_acts;
create trigger trg_act_quota before insert on public.memorial_acts
  for each row execute function public.check_act_quota();
