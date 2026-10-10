// Supabase Edge Function: memorial
// 公开纪念页（规划文档 5.4.2）：?p=<personId>
//   GET  → 渲染只读 HTML（姓名/生卒/纪念文字/计数/最近留言）
//   POST → 网页匿名献花（kind=flower|candle|prayer，走 public_tribute 限额）
// 安全：仅暴露 allow_public_link=true 且已故人物的受限字段。
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const THEME: Record<string, { bg: string; accent: string; label: string }> = {
  western: { bg: '#FBEFD8', accent: '#C87A1E', label: '🌸' },
  east_asian: { bg: '#F7E4E2', accent: '#B4433A', label: '🕊️' },
  latin: { bg: '#FCEBD2', accent: '#D2662A', label: '🌼' },
  jewish: { bg: '#E7EDEF', accent: '#6B7F8F', label: '🪨' },
  hindu: { bg: '#FBE9D2', accent: '#C87A1E', label: '🪔' },
  islamic: { bg: '#E1F0E8', accent: '#2E6B4F', label: '🕌' },
  secular: { bg: '#EDEAE4', accent: '#5C574F', label: '🕯️' },
};

function esc(s: unknown): string {
  return String(s ?? '')
    .replaceAll('&', '&amp;').replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;').replaceAll('"', '&quot;');
}

function fmtDate(d: string | null): string {
  if (!d) return '';
  const dt = new Date(d);
  return dt.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const pid = url.searchParams.get('p');
  if (!pid || !/^[0-9a-f-]{36}$/i.test(pid)) {
    return new Response('Bad request', { status: 400 });
  }
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
  );

  // 网页献花
  if (req.method === 'POST') {
    const form = await req.formData();
    const kind = String(form.get('kind') ?? '');
    const name = String(form.get('name') ?? '');
    if (!['flower', 'candle', 'prayer'].includes(kind)) {
      return new Response('Bad kind', { status: 400 });
    }
    const { error } = await supabase.rpc('public_tribute', {
      pid, kind, display_name: name,
    });
    if (error) {
      return Response.redirect(`${url.origin}${url.pathname}?p=${pid}&err=1`, 303);
    }
    return Response.redirect(`${url.origin}${url.pathname}?p=${pid}&thanks=${kind}`, 303);
  }

  const { data, error } = await supabase.rpc('get_public_memorial', { pid });
  if (error || !data) {
    return new Response(
      `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
       <body style="font-family:system-ui;background:#F7F5F1;color:#5C574F;display:grid;place-items:center;height:100vh;margin:0">
       <div style="text-align:center"><div style="font-size:40px">🕯️</div><p>This memorial page is not public.</p></div></body>`,
      { status: 404, headers: { 'content-type': 'text/html; charset=utf-8' } },
    );
  }

  const m = data as {
    name: string; birth: string | null; death: string | null;
    epitaph: string | null; theme: string;
    counts: { flower: number; candle: number; incense: number; prayer: number };
    messages: { author: string; body: string; at: string }[];
  };
  const th = THEME[m.theme] ?? THEME.western;
  const years = [fmtDate(m.birth), fmtDate(m.death)].filter(Boolean).join(' – ');
  const params = url.searchParams;
  const thanks = params.get('thanks');

  const msgHtml = m.messages.length === 0
    ? `<p style="color:#8B857C;font-size:14px">—</p>`
    : m.messages.map((msg) => `
      <div style="padding:12px 0;border-bottom:1px solid rgba(0,0,0,.06)">
        <div style="font-weight:600;font-size:14px">${esc(msg.author)}</div>
        <div style="font-size:14.5px;color:#5C574F;margin-top:3px;line-height:1.55">${esc(msg.body)}</div>
      </div>`).join('');

  const html = `<!doctype html>
<html lang="en"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>In Loving Memory · ${esc(m.name)}</title>
<style>
  body{margin:0;font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;background:#F7F5F1;color:#1A1917}
  .hero{background:linear-gradient(168deg,#211D28,#3A3040 44%,#6B5568);padding:56px 24px 72px;text-align:center}
  .arch{width:84px;height:78px;margin:0 auto 18px;border:1.5px solid rgba(255,236,206,.25);border-bottom:0;border-radius:42px 42px 0 0;display:grid;place-items:center;font-size:30px}
  h1{color:#fff;font-size:26px;margin:0;letter-spacing:-.02em}
  .dates{color:rgba(255,255,255,.8);font-size:14px;margin-top:6px}
  .card{max-width:560px;margin:-44px auto 0;background:#fff;border:1px solid #E6E1D9;border-radius:18px;padding:22px;text-align:center}
  .loving{font-size:11px;letter-spacing:.1em;text-transform:uppercase;color:#8B857C;font-weight:700}
  .epitaph{font-style:italic;color:#5C574F;font-size:15px;margin-top:10px;line-height:1.6}
  .counts{display:flex;justify-content:center;gap:26px;margin-top:18px;font-size:14px;color:#5C574F;font-weight:600}
  .sect{max-width:560px;margin:26px auto;padding:0 16px}
  .sect h2{font-size:12.5px;letter-spacing:.06em;text-transform:uppercase;color:#8B857C}
  form{display:flex;gap:8px;max-width:560px;margin:14px auto;padding:0 16px}
  input{flex:1;height:44px;border-radius:12px;border:1px solid #D8D2C7;background:#fff;padding:0 14px;font-size:14px;outline:none}
  button{height:44px;border:0;border-radius:12px;background:${th.accent};color:#fff;font-weight:600;font-size:14px;padding:0 18px;cursor:pointer}
  .thanks{max-width:560px;margin:12px auto;padding:0 16px}
  .thanks div{background:${th.bg};border-radius:12px;padding:12px 16px;font-size:14px;color:#5C574F}
  .note{max-width:560px;margin:20px auto 40px;padding:0 16px;text-align:center;color:#B4AEA4;font-size:12px;line-height:1.6}
</style></head>
<body>
  <div class="hero">
    <div class="arch">${th.label}</div>
    <h1>${esc(m.name)}</h1>
    <div class="dates">${esc(years)}</div>
  </div>
  <div class="card">
    <div class="loving">In Loving Memory</div>
    ${m.epitaph ? `<div class="epitaph">“${esc(m.epitaph)}”</div>` : ''}
    <div class="counts">
      <span>🌸 ${m.counts.flower}</span>
      <span>🕯️ ${m.counts.candle}</span>
      <span>🙏 ${m.counts.prayer}</span>
    </div>
  </div>
  ${thanks ? `<div class="thanks"><div>Your tribute was offered. Thank you.</div></div>` : ''}
  ${params.get('err') ? `<div class="thanks"><div>Couldn't offer the tribute right now. Please try again later.</div></div>` : ''}
  <form method="post">
    <input name="name" maxlength="40" placeholder="Your name (optional)">
    <select name="kind" style="height:44px;border-radius:12px;border:1px solid #D8D2C7;background:#fff;padding:0 10px;font-size:14px">
      <option value="flower">🌸 Flower</option>
      <option value="candle">🕯️ Candle</option>
      <option value="prayer">🙏 Prayer</option>
    </select>
    <button type="submit">Offer</button>
  </form>
  <div class="sect">
    <h2>Messages</h2>
    ${msgHtml}
  </div>
  <div class="note">
    Kept with Lararium — the shrine your family keeps.<br>
    Visible via a private link shared by the family.
  </div>
</body></html>`;

  return new Response(html, {
    headers: {
      'content-type': 'text/html; charset=utf-8',
      'cache-control': 'no-store',
    },
  });
});
