-- 补充 person-photos 的 UPDATE 策略。
-- Storage 的 upsert（uploadBinary upsert:true 覆盖已有对象）会走
-- INSERT ... ON CONFLICT DO UPDATE，只有 INSERT 策略时二次上传报
-- "new row violates row-level security policy"（403）。
create policy "photos update: tree editors" on storage.objects
    for update to authenticated
    using (
        bucket_id = 'person-photos'
        and public.is_tree_member(public.path_tree_id(name), 'editor')
    )
    with check (
        bucket_id = 'person-photos'
        and public.is_tree_member(public.path_tree_id(name), 'editor')
    );
