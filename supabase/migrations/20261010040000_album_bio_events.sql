-- 人物相册 + 简介 + 自定义大事记：公开纪念页扩展。
-- 1) person-album 私密桶（路径 tree_<treeId>/person_<personId>/<mediaId>.jpg，
--    复用 path_tree_id 解析树归属）
insert into storage.buckets (id, name, public)
values ('person-album', 'person-album', false)
on conflict (id) do nothing;

drop policy if exists "album read: tree members" on storage.objects;
create policy "album read: tree members" on storage.objects
    for select to authenticated
    using (bucket_id = 'person-album'
        and public.is_tree_member(public.path_tree_id(name)));

drop policy if exists "album write: tree editors" on storage.objects;
create policy "album write: tree editors" on storage.objects
    for insert to authenticated
    with check (bucket_id = 'person-album'
        and public.is_tree_member(public.path_tree_id(name), 'editor'));

drop policy if exists "album update: tree editors" on storage.objects;
create policy "album update: tree editors" on storage.objects
    for update to authenticated
    using (bucket_id = 'person-album'
        and public.is_tree_member(public.path_tree_id(name), 'editor'))
    with check (bucket_id = 'person-album'
        and public.is_tree_member(public.path_tree_id(name), 'editor'));

drop policy if exists "album delete: tree editors" on storage.objects;
create policy "album delete: tree editors" on storage.objects
    for delete to authenticated
    using (bucket_id = 'person-album'
        and public.is_tree_member(public.path_tree_id(name), 'editor'));

-- 分享页匿名只读：仅 allow_public_link + is_enabled 人物的相册对象可见
drop policy if exists "album public read when shared" on storage.objects;
create policy "album public read when shared" on storage.objects
    for select to anon
    using (bucket_id = 'person-album'
        and exists (
          select 1 from public.media m
          join public.memorial_profiles mp on mp.person_id = m.person_id
          where m.storage_path = storage.objects.name
            and mp.allow_public_link = true
            and mp.is_enabled = true
        ));

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
