# Lararium · 工作进度台账

> 规则见 `.codebuddy/rules/work-log.md`：每次任务完工后必须更新本文件。
> 新接手的 AI / 开发者：**请先读本文件 + `docs/家谱树App整体开发规划.md` 再动手。**

## 项目一句话

面向海外市场的家谱树 App（Flutter + Supabase），对标 FamilySearch Tree 与 Quick Family Tree。
差异化：**本地优先（免注册/离线）** + **首版 12 语言自动匹配** + **缅怀纪念（献花/点烛/上香/留言）**。

## 已定稿决策

| 项 | 结论 |
|---|---|
| App 名 | 🏆 **Lararium**（首选，49 个候选中首个零占用）｜备选 Caristia / Vinora —— 待 USPTO 核验，见 `docs/…11.6` |
| 包名 / Bundle ID | ✅ **`com.ay1px.tree`**（Android + iOS 一致），**与品牌名解耦**。Flutter 项目已用此包名创建 |
| Play 标题 | **`Lararium: Family Tree`**（21 字符；改标题无需发版） |
| Slogan | *The shrine your family keeps.* |
| 首版语言 | 12 种：en / es / pt / fr / de / it / ja / ko / zh-Hans / zh-Hant / ru / nl（**ARB 已全部写完**） |
| 默认语言 | 按设备 locales 列表自动匹配（5.3.2 算法已实现），可应用内覆盖 |
| 缅怀主题包 | 按地区自动推荐 + 首次弹层可自选一次（人物级，随时可改）—— 已实现 |
| 免费版额度 | 献花/点烛/上香/祈福 各 1 次/天，留言 3 条/天，忌日当天该人物 +1（**服务端触发器已实现**，客户端额度 UI 待接云后启用） |
| 技术栈 | Flutter 3.24.5 + Riverpod + go_router + Drift(SQLite 本地真源) + Supabase（outbox 同步，待接） |
| 目标平台 | Google Play 先发（模拟器已跑通），效果好再上 iOS |

---

## ✅ 已完成（Done）

### 2026-10-09 · Flutter 本地内核（阶段 1 提前完成）+ i18n（阶段 4 主体）+ 缅怀核心（阶段 5 主体）

| 产物 | 路径 | 说明 | 验收方式 |
|---|---|---|---|
| Flutter 工程 | 仓库根目录 | `flutter create --org com.ay1px`（applicationId=com.ay1px.tree），依赖：riverpod/go_router/drift/sqlite3/shared_preferences/intl | `flutter analyze` 0 error |
| 主题 | `lib/core/theme.dart` | 原型暖纸色系 1:1 移植（ThemeExtension，明/暗双套） | 模拟器截图 `screenshots/` |
| 语言自动解析 | `lib/core/locale_resolver.dart` | 5.3.2 算法：用户覆盖 > 系统 locales 逐个匹配 > zh 简繁判定 > 兜底 en | 设置页实测：选简体中文全 UI 即时切换 |
| 日期/格式化 | `lib/core/fuzzy_date.dart` `format.dart` | YYYY / YYYY-MM / YYYY-MM-DD 三档模糊日期；DateFormat 按 locale | 编辑人物页输入验证 |
| 路由 | `lib/core/router.dart` | go_router + StatefulShellRoute：树/人物/纪念/设置 4 Tab 常驻 + memorial/edit/add/search/export/import 全屏路由 | 模拟器逐屏点验 |
| Drift 数据库 | `lib/data/db/` | 5 表：trees/persons/families/family_children/memorial_messages（含缅怀计数列、messageCount），schemaVersion=1 | `dart run build_runner build` 通过 |
| 家庭关系服务 | `lib/data/repositories/family_service.dart` | 添加父母/配偶/子女/兄弟姐妹 → 自动建/复用 families + family_children（含父母位已满、无父母家庭等边界） | 树视图加人验证 |
| 演示数据 | `lib/data/repositories/demo_seed.dart` | Carter 家族 10 人 3 族 4 代 + 6 条留言（空库自动播种） | 首启即有完整家族 |
| **树布局引擎** | `lib/features/tree/layout/tree_layout.dart` | 家庭单元级 Reingold–Tilford 轮廓布局；**签名显式接收 TextDirection**（RTL 整体镜像预埋）；夫妻并排/子女居中/正交连线 | 截图 01_tree.png |
| 树渲染 | `lib/features/tree/tree_painter.dart` | CustomPaint：节点卡/头像渐变/**已故去饱和**/焦点环/YOU 徽标/正交连线 | 截图 01_tree.png |
| 树手势 | `lib/features/tree/tree_screen.dart` | 单指平移/双指与滚轮缩放/**6px 阈值防误触**/±/适应屏幕按钮（对标 FS 差评 #1） | 模拟器滑动点按 |
| 人物 Sheet | `lib/features/person/person_sheet.dart` | 详情/档案/缅怀卡(已故)/添加亲属 4 按钮/编辑入口 | 点树节点验证 |
| 编辑人物 | `lib/features/person/edit_person_screen.dart` | 预填表单/性别 chips/已故开关(显隐逝世字段)/删除确认 | |
| 添加亲属 | `lib/features/person/add_relative_screen.dart` | 关系 4 选卡/姓自动继承/名必填校验 | |
| 人物列表 | `lib/features/people/people_screen.dart` | Living/Remembered 分组、已故头像去饱和 | |
| 搜索 | `lib/features/search/search_screen.dart` | 姓名/年份/地点/职业实时过滤 | |
| **纪念墙** | `lib/features/memorial/memorial_wall_screen.dart` | All/Recent/This month/Anniversaries 筛选 + 计数卡 | 截图 03_wall.png |
| **纪念页** | `lib/features/memorial/memorial_screen.dart` | 壁龛拱形英雄区 + 引言卡 + 主题 chip + 动作栏 + **两步确认致敬**（选中→舞台预览→Send 才计数→Sent ✓ 锁定）+ 留言墙 + 底部输入 | 截图 05b/05c |
| **缅怀特效** | `lib/features/memorial/fx_stage.dart` | CustomPaint 自绘：花瓣飘落/五瓣花束(牛皮纸包装)/烛焰摇曳/油灯/青烟粒子/祈福光点/鞠躬/放石 —— 零依赖零版权 | 截图 05b |
| **7 套主题包** | `lib/features/memorial/memorial_theme_defs.dart` | 配色 1:1 移植原型 + 12 种致敬动作 + 地区推荐映射（5.4.3-B） | 切语言联动推荐主题 |
| 主题选择弹层 | `lib/features/memorial/theme_picker_sheet.dart` | 7 主题 + Recommended 标签 + Use recommended（人物级保存） | |
| 设置 | `lib/features/settings/` | 语言(12+跟随系统)/默认缅怀方式/深色模式/隐私/账号删除入口(合规占位) | 截图 04 |
| **12 语言 ARB** | `lib/l10n/app_*.arb`（12+zh 回退） | **全部人工写完**（复用原型已评审译法），ICU 复数（ru 4 形式），`flutter gen-l10n` 通过，无缺失 key | 模拟器 en↔zh-Hans 实测 + 姓名顺序姓前 |
| Supabase 建表 SQL | `supabase/migrations/20261009000000_init.sql` | 6.3+6.7 全量：14 表 + updated_at/计数冗余/在世者关闭缅怀触发器 + **RLS（SECURITY DEFINER 防递归）** + 每日额度限制(忌日+1) | `supabase db push`（待项目创建后执行） |
| 网页(GitHub Pages 用) | `web/index.html` `web/privacy.html` | 品牌落地页 + **隐私政策**（Play 合规必需；本地优先/UGC/删除入口条款齐全） | 浏览器打开 |
| Android 应用名 | `android/app/src/main/AndroidManifest.xml` | label=Lararium | 模拟器桌面图标名 |
| **Supabase 项目** | dashboard: project/sdxhduusacwnimcrkkqv | lararium · us-east-1 · org ootaslntjxpugdgtipus；CLI 已 login（access token `lararium-cli` 存于 ~/.supabase） | `supabase projects list` |
| **云端建表** | `supabase/migrations/20261009000000_init.sql` | `db push` 成功：trees/tree_members/persons/families/family_children/events/media/invites + memorial_* 5 表 + RLS（SECURITY DEFINER）+ 计数/在世者关闭缅怀/每日额度触发器 | `supabase db push --dry-run` 显示 up to date |
| **App 云配置** | `lib/core/cloud_config.dart` + main.dart | supabase_flutter ^2.8.4 接入，Supabase.initialize 免登录可用（本地真源原则不变）；URL+anon key 内置，支持 --dart-define 覆盖 | `flutter analyze` 0 error |

**模拟器验证记录**（Pixel_10a / API16k，截图在 `screenshots/`）：
欢迎页（壁龛 logo）→ 树视图（10 人 4 代连线正确、已故「1918 – 1994」去饱和、YOU+焦点环）→ 纪念墙（3 位追忆、筛选 chips、计数）→ 纪念页（英雄区/引言/动作栏/两步确认：Flowers 32→选中预览→Send→33 + Sent ✓）→ 设置 → 语言切简体中文（全 UI 即时切换、姓名变「Carter James」姓前、徽标「我」、「生于 1948」）。
**已知已修 bug**：演示数据 isLiving 未标记（已修）；Container 负 margin 红屏（改 Transform.translate）；FX 舞台宽度塌陷（width: double.infinity）。

### 此前完成（文档与原型阶段）

| 产物 | 路径 | 说明 | 验收方式 |
|---|---|---|---|
| 竞品调研 + 整体规划 | `docs/家谱树App整体开发规划.md` | 18 周排期、P0/P1/P2、合规清单 | 打开文档 |
| 品牌定名 | 同上 · 11.6 | Lararium 定稿；47 个候选墓地留档 | 打开文档 |
| HTML 交互原型 v2 | `prototype/index.html` | 15 屏 + 3 弹层，12 语言，明暗双主题 | `python3 -m http.server 8899` |
| 进度记录规则 | `.codebuddy/rules/work-log.md` | 强制三段式 | 打开文档 |

---

## 🚧 进行中（In Progress）

1. **GitHub 授权最后一步**：设备码流程已走通到「密码确认」页（GitHub sudo 模式），**等你在 ZCode 浏览器窗口输入 GitHub 密码点 Confirm**。完成后我立即：建仓库 → push → 开 Pages。
2. **Supabase 已完成 ✅**（详见 Done）：项目 lararium（ref: sdxhduusacwnimcrkkqv，us-east-1）、14 表 + RLS + 触发器已推送、anon key 已写入 App（`lib/core/cloud_config.dart`）、DB 密码在 `supabase/.db_password_local`（不入库）。

---

## ⬜ 未开始（Not Started）

按规划文档阶段排期（已大幅提前完成阶段 1/4/5 主体）：

1. **原型差异扫尾**：导出 PDF/PNG/GEDCOM（阶段 2，解析器 ~3-5 天）；GEDCOM 导入；自家 JSON 备份
2. **云同步（阶段 3）**：supabase_flutter 接入 + Auth（邮箱/Google/Apple）+ outbox 推拉引擎 + 冲突 LWW + 同步状态 UI + 媒体上传（压缩队列）+ 邀请链接协作
3. **缅怀云化**：memorial_acts 走云（额度触发器已备）、Realtime「John 刚刚献了一束花」、忌日本地通知（flutter_local_notifications）、Web 纪念页（Edge Function + Pages）
4. 原型中的 Sync & Share / Pro 付费页（接 billing 后做）
5. 伪语言溢出扫描 + de/ja/ar 真机矩阵（阶段 4 收尾）
6. 🔴 **Play Console 建空壳草稿占位 `com.ay1px.tree`**（包名永久不可改；需要你的 Google 账号操作）
7. 核验 Lararium（USPTO TESS 第 9/42 类 + lararium.com + 社交账号）
8. 注册 Play 开发者账号 + 启动 20 人 × 14 天封闭测试
9. 上架素材（图标/截图 5-8 张 × 主要语言）+ 数据安全表单 + UGC 声明

---

## 备注 / 已知风险

- **Flutter 版本**：本机 3.24.5（Dart 3.5.4）—— 注意：`Color.withValues`/`CardThemeData` 等 3.27+ API 不可用；intl 锁 0.19.0。升级 Flutter 前先改 pubspec。
- **留言作者名**：本地阶段写死 'You'，阶段 3 接 Auth 后替换为账号名。
- **免费额度**：客户端 UI 提示暂未接（等服务端 quota 触发器上线后按 `{allowed, remaining, resetAt}` 渲染）。
- **Supabase 免费层 1 周不活跃暂停**：建项后用 GitHub Actions 每日 ping；发布当月升 Pro（$25/月）。
- Google Play **包名一经发布永久不可更改** → 尽早在 Play Console 建草稿实测 `com.ay1px.tree`。
- 缅怀留言属 UGC → Play 必填「用户生成内容」问卷；App 内举报/屏蔽/管理员删除已在 schema 与规划中预留。
- 🔴 **品牌名 Lararium 待权威核验**（USPTO TESS + Play Console + 域名/社交账号），未核验前不印实体物料。
- Supabase CLI 交互式登录在无 TTY 环境需 `expect` 包装或直接用 access token。
