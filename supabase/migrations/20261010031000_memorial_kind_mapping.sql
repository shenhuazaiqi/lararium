-- 缅怀计数触发器补全 kind 映射（对齐 App 端语义：鞠躬/捐赠计入 prayer，
-- 万寿菊/花环计入 flower，油灯/祭坛/放石计入 candle），
-- 并让公开 RPC 的 tributes 携带 item_code（网页按 item 显示更准确的动词）。

create or replace function public.bump_memorial_count()
returns trigger language plpgsql as $$
declare
  col text;
begin
  col := case new.kind
    when 'flower'    then 'flower_count'
    when 'marigold'  then 'flower_count'
    when 'garland'   then 'flower_count'
    when 'candle'    then 'candle_count'
    when 'diya'      then 'candle_count'
    when 'ofrenda'   then 'candle_count'
    when 'stone'     then 'candle_count'
    when 'incense'   then 'incense_count'
    when 'prayer'    then 'prayer_count'
    when 'bow'       then 'prayer_count'
    when 'donation'  then 'prayer_count'
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

-- tributes 携带 item_code
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
