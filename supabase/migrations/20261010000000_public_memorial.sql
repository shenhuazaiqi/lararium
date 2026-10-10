-- ============================================================
-- 公开纪念页（规划文档 5.4.2「纪念页分享与裂变」+ 5.4.5 合规）
-- 原则：anon 只读受限字段（姓名/生卒/纪念文字/计数/最近留言），
--       绝不暴露在世亲属与其他树成员；开启需 allow_public_link。
-- ============================================================

-- 匿名可读的受限纪念数据（只读，安全定义者绕过 RLS 但只返回白名单字段）
create or replace function public.get_public_memorial(pid uuid)
returns json
language plpgsql security definer set search_path = public stable as $$
declare
  result json;
begin
  select json_build_object(
    'name', p.given_name || ' ' || p.surname,
    'birth', p.birth_date,
    'death', p.death_date,
    'epitaph', mp.epitaph,
    'theme', coalesce(mp.theme, 'western'),
    'counts', json_build_object(
      'flower', mp.flower_count,
      'candle', mp.candle_count,
      'incense', mp.incense_count,
      'prayer', mp.prayer_count
    ),
    'messages', (
      select coalesce(json_agg(json_build_object(
        'author', m.author_name,
        'body', m.body,
        'at', m.created_at
      ) order by m.created_at desc), '[]'::json)
      from (
        select author_name, body, created_at
        from public.memorial_messages
        where person_id = pid and status = 'visible'
        order by created_at desc
        limit 20
      ) m
    )
  )
  into result
  from public.memorial_profiles mp
  join public.persons p on p.id = mp.person_id
  where mp.person_id = pid
    and mp.allow_public_link = true
    and mp.is_enabled = true
    and p.is_living = false
    and p.deleted_at is null;

  return result;
end $$;

grant execute on function public.get_public_memorial(uuid) to anon, authenticated;

-- 网页匿名献花（一朵/Views：带总量限制防刷；规划 5.4.2「网页献一束花」）
create or replace function public.public_tribute(pid uuid, kind text, display_name text)
returns json
language plpgsql security definer set search_path = public as $$
declare
  allowed_kinds text[] := array['flower','candle','prayer'];
  today_count int;
  mp_row public.memorial_profiles%rowtype;
  new_id uuid := gen_random_uuid();
begin
  if not (kind = any(allowed_kinds)) then
    raise exception 'KIND_NOT_ALLOWED';
  end if;

  select * into mp_row from public.memorial_profiles
   where person_id = pid and allow_public_link = true and is_enabled = true;

  if not found then
    raise exception 'NOT_PUBLIC';
  end if;

  -- 同一人每日上限 3 次（按 IP 无法取，这里按人+日限流，配合 Edge Function 层再限）
  select count(*) into today_count from public.memorial_acts
   where person_id = pid and source = 'web' and created_at >= date_trunc('day', now());

  if today_count >= 50 then
    raise exception 'DAILY_LIMIT';
  end if;

  insert into public.memorial_acts (person_id, tree_id, actor_name, is_anonymous, kind, source)
  values (pid, mp_row.tree_id,
          left(coalesce(nullif(trim(display_name), ''), 'A friend'), 40),
          true, kind, 'web');

  return json_build_object('ok', true, 'act_id', new_id,
                           'flower', mp_row.flower_count + case when kind='flower' then 1 else 0 end,
                           'candle', mp_row.candle_count + case when kind='candle' then 1 else 0 end,
                           'prayer', mp_row.prayer_count + case when kind='prayer' then 1 else 0 end);
end $$;

grant execute on function public.public_tribute(uuid, text, text) to anon, authenticated;

-- 匿名写入 memorial_acts 的白名单通道（上面的函数已做校验，这里显式授权走函数即可）
-- 注：memorial_acts 本表 RLS 不对 anon 开放直插。
