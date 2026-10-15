// 公开分享页的相册签名 URL：匿名 POST { pid } → 仅当该纪念页已开启公开链接时
// 返回相册图片的签名 URL 列表（7 天有效）。service role 由部署时自动注入。
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "content-type",
      },
    });
  }
  try {
    const { pid } = await req.json();
    if (!pid || !/^[0-9a-f-]{36}$/i.test(pid)) {
      return Response.json({ error: "BAD_PID" }, { status: 400 });
    }
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: mp } = await admin
      .from("memorial_profiles")
      .select("allow_public_link, is_enabled")
      .eq("person_id", pid)
      .single();
    if (!mp?.allow_public_link || !mp?.is_enabled) {
      return Response.json({ error: "NOT_PUBLIC" }, { status: 403 });
    }
    const { data: media, error: mErr } = await admin
      .from("media")
      .select("storage_path, caption")
      .eq("person_id", pid)
      .eq("kind", "photo")
      .is("deleted_at", null)
      .not("storage_path", "is", null)
      .order("created_at", { ascending: false })
      .limit(30);
    const album = await Promise.all(
      (media ?? []).map(async (m) => {
        const { data, error: sErr } = await admin.storage
          .from("person-photos")
          .createSignedUrl(m.storage_path!, 604800);
        return { url: data?.signedUrl ?? "", caption: m.caption, sErr: sErr?.message ?? null };
      }),
    );
    return Response.json(
      { debug: { raw: (media ?? []).length, album } },
      { headers: { "Access-Control-Allow-Origin": "*" } },
    );
  } catch (_) {
    return Response.json({ error: "FAILED" }, { status: 500 });
  }
});
