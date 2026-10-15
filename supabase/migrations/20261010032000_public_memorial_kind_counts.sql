-- 公开纪念页：kind_counts（全部缅怀方式的计数聚合，来自 memorial_acts）。
-- 分享页计数卡直接展示全部 12 种图标；核心 4 类仍以 memorial_profiles 冗余列为准。
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
    'kind_counts', (
      select coalesce(json_object_agg(kind, c), '{}'::json)
      from (
        select kind, sum(quantity) as c
        from public.memorial_acts
        where person_id = pid
        group by kind
      ) t
    ),
    'tributes', (
      select coalesce(json_agg(json_build_object(
        'who', a.actor_name,
        'kind', a.kind,
        'item', a.item_code,
        'at', a.created_at
      ) order by a.created_at desc), '[]'::json)
      from (
        select actor_name, kind, item_code, created_at
        from public.memorial_acts
        where person_id = pid
        order by created_at desc
        limit 50
      ) a
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
