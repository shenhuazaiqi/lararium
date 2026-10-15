-- 人物相册 + 简介 + 自定义大事记：公开纪念页扩展。
-- 1) 人物相册桶 person-album 设为 public：公开分享页直接经
--    /storage/v1/object/public/person-album/<path> 读取（路径含不可猜测的
--    mediaId UUID，等同于「分享链接即凭证」；成员写入仍走 RLS 策略）。
--    注：私密桶对匿名不可见，签名 URL 的 SQL 函数在本项目 schema 中不存在，
--    故采用 public 桶方案。
update storage.buckets set public = true where id = 'person-album';

-- 2) 公开 RPC 扩展：bio（人物简介 = persons.note）、album（签名 URL 相册）、
--    events（自定义大事记）。仅在 allow_public_link 开启时随整体返回。
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
    'bio', p.note,
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
    'album', (
      select coalesce(json_agg(json_build_object(
        'path', m.storage_path,
        'caption', m.caption
      ) order by m.created_at), '[]'::json)
      from (
        select storage_path, caption, created_at
        from public.media
        where person_id = pid and deleted_at is null
          and kind = 'photo' and storage_path is not null
        order by created_at desc
        limit 30
      ) m
    ),
    'events', (
      select coalesce(json_agg(json_build_object(
        'title', e.description,
        'date', e.date_from,
        'place', e.place_text
      ) order by e.date_from), '[]'::json)
      from (
        select description, date_from, place_text
        from public.events
        where person_id = pid and deleted_at is null and type = 'custom'
        order by date_from
        limit 50
      ) e
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
