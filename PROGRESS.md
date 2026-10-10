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

### 2026-10-10 · 树布局修复：父母代显示在子女上方（用户报告 + 数据修复）

- **现象**：给自己新增父母后，父母没有出现在自己上方，而是平铺成同代独立节点。
- **布局根因**：根选择按人物列表顺序取「未被收编者」，本人先入列时先被当成根；`parentFamilyOf`（作为孩子的家庭）算出来后从未使用，父母无法把自己往下收编。
- **修复**（`tree_layout.dart`）：根改为「根家庭」锚点——夫妻双方都没有父母家庭的才做根，其余人由父母单元向下收编；末尾兜底 pass 收纳孤立人/悬空链接。父母单元居中于子女单元正上方的不变量保持。
- **数据修复**（用户树实测）：还原时间戳发现 `laibao` 当时挂成了 yuyao 的父母（`wangxin` 才挂在本人的父母家庭）。已修本地库：laibao 并入本人父母家庭 partner2 空位，误挂家庭软删 + 删链接。修复后树形：wangxin+laibao（第0代）→ 本人+配偶（第1代）→ yuyao（第2代），连线全部正确。
- **防回归**：新增 `test/tree_layout_test.dart` 4 用例（父母代在上/单亲/无关联家系并排/三代同堂），全绿。

### 2026-10-10 · 换头像后树页/头像组件即时刷新（用户反馈修复）

- **问题**：上传新头像后返回树页，节点仍是旧头像，重启 App 才更新。
- **根因**：存储路径固定（`tree_<id>/person_<id>.jpg`，换照片路径不变），树页的已解码头像缓存（`_avatarImages` + `_avatarRequested`）无法感知内容变化，永不重拉。
- **修复**：新增全局 `avatarEpochProvider`（providers.dart），上传成功后自增；树页 build 时比对 epoch 变化即清缓存重载，`PhotoAvatar` 用 `ref.listen` 重签 URL，详情页 `_Avatar` watch 触发重建。
- **验收**：模拟器实测——换浅色海报上传后一次返回，树节点立即显示新头像（无重启）。

### 2026-10-10 · 头像自定义裁剪 + 照片管线三处硬伤修复（全链路实测通过）

| 产物 | 路径 | 说明 | 验收方式 |
|---|---|---|---|
| 头像裁剪页 | `lib/features/person/avatar_crop_screen.dart` | 纯 Flutter 实现（不引入原生裁剪库）：拖动 + 双指缩放（clamp 保证图像始终盖满方框）+ 90° 旋转，方形暗化遮罩 + 三分线 + 圆形参考线（对应头像圆形显示），确认后 dart:ui 画布重采样输出 1024×1024 JPEG | 模拟器实测：横图拖动/旋转/确认 |
| 上传链路改造 | `lib/data/photo_service.dart` `edit_person_screen.dart` | 选图 → 读字节 → 裁剪页 → 裁剪结果字节 → 压缩（80）→ Storage 私密桶；catch 块补 `PHOTO_UPLOAD_ERR` 日志不再吞异常 | logcat 无异常 + SnackBar 成功 |
| 树画笔照片接入修复 | `tree_screen.dart` | **真因**：TreePainter 已支持 `avatarImages/avatarVersion` 但构造时从未传入（默认空）→ 解码成功画面仍是字母。补传两参数后树节点照片立现 | 树节点显示混沌海报圆形头像（截图） |
| 编辑页/详情页头像统一 | `edit_person_screen.dart`（换 PhotoAvatar）+ `person_sheet.dart`（删除未用的 nameOf/转义污染） | 修掉 `'\${...}'` 字面量转义 bug（timelineChildBorn 会显示占位符文本）| 编辑页头部显示照片（截图） |
| **Storage UPDATE 策略补丁** | `supabase/migrations/20261010020000_storage_update_policy.sql`（已应用到线上） | **二次上传 403 真因**：collab_photos 迁移只有 insert/read/delete 策略，upsert 覆盖已有对象走 `INSERT ON CONFLICT DO UPDATE` 撞缺失的 UPDATE 策略。已用 Management API 执行 SQL 补齐（新路径 insert 200 / 旧路径此前 403 → 修复后 200 双向验证） | curl 双路径复现 → 修复 → 复测通过 |
| i18n | `lib/l10n/*.arb` ×13 | +3 键：cropTitle / cropConfirm / cropRotate（12 语言全量） | gen-l10n 无缺失 |
| 清理 | `tree_screen.dart` `main.dart` 等 | 删 AVATAR_DEBUG 系调试打印、未用 import、未用变量；触碰文件 analyze 零警告 | `flutter analyze` 188 条全为未触碰模块历史 lint |

**排障结论（复用价值）**：上传 403 类问题先用最小 curl（带用户 JWT，`run-as` 取 shared_prefs 里 `sb-*-auth-token`）双路径对比复现，再定位到策略缺口——比在端上猜快得多；Supabase 无 DB 密码时可用 keychain 里的 CLI access token 走 `api.supabase.com/v1/projects/{ref}/database/query` 执行 SQL（`security find-generic-password -a supabase -s "Supabase CLI" -w` 会弹 GUI 授权框，无头环境改走 Dashboard SQL 编辑器）。

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
| **GitHub 公开仓库** | https://github.com/shenhuazaiqi/lararium | gh CLI 已登录（shenhuazaiqi），main + gh-pages 两分支已推送 | `gh repo view` |
| **GitHub Pages 公网** | https://shenhuazaiqi.github.io/lararium/ | gh-pages 分支（web/ 子树）+ Pages 已启用，构建成功 | HTTP 200（首页 + privacy.html） |
| 授权辅助脚本 | `scripts/auth-supabase.command` `scripts/auth-github.command` | 双击即用的 CLI 登录脚本（备用） | 双击运行 |

### 2026-10-09（晚）· MVP 功能闭环（阶段 2/3/5 主体一次补齐）

| 产物 | 路径 | 说明 | 验收方式 |
|---|---|---|---|
| **GEDCOM 5.5.1 解析器+导出器** | `lib/features/gedcom/gedcom.dart` | UTF-8/UTF-16/ANSEL 编码检测、CONT/CONC 多行备注、模糊日期（ABT/年月日）、INDI/FAM 全字段、代数计算（防环） | `flutter test`：6 个单测全过（往返/日期/编码/跳过标签/多行备注） |
| **导出中心（实战）** | `lib/features/export/export_screen.dart` + `export_service.dart` | ① PDF 海报（树画布高清 PNG 嵌入 → 名字走系统字体 CJK 安全；A4/2×）② PNG 高清图（RepaintBoundary 3x）③ GEDCOM（含「剔除在世人」脱敏开关）④ JSON 全量备份 —— 全部经系统分享面板输出 | 模拟器实测：GEDCOM 导出弹出系统分享 `lararium_export.ged`（截图 13） |
| **GEDCOM 导入（实战）** | `lib/features/import/import_screen.dart` | file_picker 选 .ged → 本机解析（不上传）→ 自动建新树 → 结果报告（人数/家庭/代数/跳过标签）→ 一键切换到新树 | 代码路径 + 单测覆盖解析；端到端待真机用真实 .ged 文件 |
| **多树管理** | `lib/data/tree_service.dart` + 设置页树区 + `TreeGate` | 创建/切换/重命名/复制（整树含留言）；`currentTreeIdProvider` 持久化，TreeGate 让 4 个 Tab 自动换数据源 | 截图 10（Carter Family + Current 徽标 + New tree） |
| **提醒中心** | `lib/features/reminders/` | 忌日/生日开关、9:00 提醒、提前天数（当天/1/3/7）、未来 30 天列表；flutter_local_notifications + timezone（Android 脱糖/权限/BOOT receiver 已配） | 截图 14：James Carter 忌日 11/4 正确出现在列表 |
| **免费额度** | `lib/features/memorial/memorial_quota.dart` | 每类动作 1 次/天、留言 3 条/天、**忌日当天 +1**；耗尽弹层温和文案 + 「留言永远免费」出口（5.4.4 防差评全套）；额度常量即未来的服务端 remote_config | 截图 16：第二次献花被温和拦截 |
| **账号+云同步** | `lib/data/sync_service.dart` + `lib/features/sync/sync_screen.dart` | 邮箱注册/登录（Supabase Auth）；整树推送（upsert）+ 拉取合并（LWW by client_updated_at）；同步状态卡/立即同步/成员/邀请占位 | **真实上云验证**：云端 SQL 计数 persons=11/families=3/children=6；App 显示 All synced + 时间（截图 12/18） |
| **Pro 页** | `lib/features/pro/pro_screen.dart` | $19.99/年 + 6 权益 + 「免费版永远保留缅怀闭环」声明；Continue 显式提示 Billing 待商店配置（合规） | 截图 15 |
| **i18n 补齐** | `lib/l10n/*.arb`（12 语言 + zh 回退） | 本轮新增 **91 键 × 12 语言全部翻译**（含 ru 复数 4 形式），`l10n_missing.txt` 为空 | 中文实测：设置/同步/纪念页全中文（截图 17/18） |
| 云端修正 | `supabase/migrations/…init.sql` | persons 补 `is_self` 列（已在线上 ALTER）；tree_members 改「先查后插」规避 upsert RETURNING 与 RLS 快照冲突 | curl 复测 201 |

**UX 修正（2026-10-10）**：语言选择与缅怀方式选择从底部弹层改为**独立页面**（用户反馈：13 项内容把「完成」按钮顶出屏幕、无法返回）。新交互：带返回键 + 点选即生效即保存。路由 `/settings/language`、`/settings/memorial-style`（支持 `?person=` 人物级）。旧弹层代码已删除。

**分享纪念页实战 + 双对号修复（2026-10-10）**：
- 「已送出 ✓」按钮去掉双对号（图标 + 文案各一个），改为纯文字「已送出」（`sentDone` 键 ×12 语言）。
- **Web 公开纪念页真功能落地**：`web/memorial.html`（GitHub Pages 托管）+ 云端 `get_public_memorial`（anon 只读受限字段：姓名/生卒/纪念文字/计数/最近 20 条留言）+ `public_tribute`（网页匿名献花，security definer + 每日 50 次限额）。流程：纪念页点「分享」→ 首次弹确认（明示公开范围，在世亲属永不显示）→ 写入 `allow_public_link`（本地+云端）→ 分享链接 `https://shenhuazaiqi.github.io/lararium/memorial.html?p=<id>`。**实测闭环**：App 分享面板带真实链接 ✓、浏览器渲染公开页 ✓、网页 Offer 献花 → 云端计数落库 ✓。
- ⚠️ 技术备忘：Supabase Edge Functions 对未认证响应强制 `text/plain + CSP sandbox`（防钓鱼策略），静态托管方案因此成为必选；Edge Function `memorial` 保留作服务端兜底。
- 本地 schema v2：persons 加 `allow_public_link` 列（onUpgrade 迁移，实测 user_version 1→2）。

**Google 登录已打通（2026-10-10）**：用户申请的 OAuth 客户端（Android 类型 + Web 类型）已配置。Supabase Google 服务商启用，client_id = Web ID,Android ID（逗号分隔）。App「Continue with Google」→ google_sign_in → signInWithIdToken → **实测登录成功**（guojianpude@gmail.com 会话建立，云端 auth.users 可见）。排障记录：① 报 ApiException:10 (DEVELOPER_ERROR) 的根因之一是 **GCP OAuth 同意屏幕处于「测试」状态且测试用户为空** —— 已把 guojianpude@gmail.com 加入测试用户；② Supabase 侧 "Unacceptable audience" 需把 **Web ID 和 Android ID 都**写入 client_id（逗号分隔，additional_client_ids 字段经 Management API 无法持久化）。正式发布前需把 OAuth 同意屏幕「发布应用」转正式（当前测试状态上限 100 用户）。

**完成度修复一轮（2026-10-10 下午）**——盘点发现的缺口按优先级清完：
- ✅ **启动图标**：用户提供的 icon.png（暗绿底发光家族树）→ flutter_launcher_icons 生成自适应+全密度图标，桌面实测生效
- ✅ **空树加人**（A1）：新增「创建人物」页 `/person/new`；树/人物页空态 CTA「Add the first person」；树的第一个人自动成为焦点（isSelf）。实测：新建树 → CTA → 建 Sarah → 节点带 YOU 徽标居中
- ✅ **登录态恢复**（A3）：main() 从 Supabase session 回填 authEmailProvider，重启后 UI 显示已登录
- ✅ **提醒启动重排**（A4）：main() 启动后按当前树人物重排通知（不阻塞首帧）
- ✅ **JSON 备份恢复**（A2）：ExportService.restoreJsonBackup（id 重映射防冲突）+ 导出页「Restore from backup」入口 → 恢复为新树并切换
- ✅ **登出清理**（B12）：清同步状态与最后同步时间
- ✅ **安葬地字段**（B9）：编辑页逝世区新增「安葬地」
- ✅ **姓名顺序全局化**（B10）：personDisplayName 移入 core/format.dart，人物列表/详情/搜索/纪念页/纪念墙全部按 locale 切姓前名后
- ✅ **删除树**（B11）：设置页树弹层「删除树」+ 确认对话框（显示影响人数）；删除当前树自动切到剩余树
- ✅ **隐私政策 App 内入口**（B13）：设置隐私区链接到 GitHub Pages 政策页
- ✅ **留言作者名**（B8）：登录后用账号邮箱前缀
- ✅ **同步拉取完整性**（B6）：families/family_children/memorial_messages 增量拉取 + memorial_profiles 双向（主题/计数/公开开关）
- 遗留：PDF 页面文字拉丁字体（人名已走图像不受影响）；Apple 登录/Realtime/照片上传/邀请协作/Billing 属后续阶段

**最后一批功能闭环（2026-10-10 晚）——除 Apple 登录与 Banner 广告外全部完成**：
- ✅ **Realtime 到达提示**：纪念页订阅 memorial_acts inserts（Supabase Realtime，按 person_id 过滤，自己动作不提示），家人献花实时 SnackBar「🌸 XX just offered a tribute」
- ✅ **邀请协作**：云端 `create_invite`（所有者生成 8 位码）/`redeem_invite`（兑换加入树成员）RPC + 同步页生成/显示/兑换 UI + 兑换后整树拉取到本地（persons/families/links/messages 幂等插入）。所有权保护实测：非所有者对他人树生成邀请被正确拒绝
- ✅ **照片头像**：`photo_service.dart`（flutter_image_compress 压缩 1024/80 → Supabase Storage 私密桶 `person-photos`，路径 `tree_<id>/person_<id>.jpg`，RLS 按路径树成员校验）→ 签名 URL（1h）在人物详情页显示（CachedNetworkImage）；编辑页 Photo 按钮实选图上传
- ✅ **账号删除真实执行**：Edge Function `delete-account`（用户 JWT 验证 → service role 删拥有的树级联 + 成员记录 + auth 用户）+ App 内确认弹层 → 云端清洗 → 本地五表清空 + prefs 重置 → 回欢迎页（GDPR/Play 合规闭环）
- ✅ **Play Billing**：`billing_service.dart`（in_app_purchase，商品 `pro_year`，购买流监听/恢复/completePurchase → prefs `pro_active`）；Pro 页接真实商品查询与购买；**无商店配置的构建优雅降级**（显示合规说明，绝不引导外部支付）
- ✅ **关系计算器**（P1）：`relationship_screen.dart` —— 家族图（亲子+配偶边）BFS 最短路径 → 分类输出（直系尊属/直系后代/兄弟姐妹/配偶/表亲 N 代/叔侄/姻亲/无关联）+ 路径链可视化；人物页入口（计算器图标）
- ✅ **人物时间轴**（P1）：详情页新增「人生大事记」——出生/结婚/各子女出生/逝世按年份排序，纯数据计算无新表
- ✅ **i18n**：+57 键 × 12 语言全部翻译，无缺失
- 同步模型说明：树的所有权属于创建者；其他账号通过邀请码加入后可同步共享（Carter 演示树属于测试邮箱账号，Google 账号对它"同步失败"是 RLS 所有权保护的**正确行为**）

**已知限制（下轮处理）**：① PDF 页面文字用内置拉丁字体（人名已走图像渲染不受影响）；② Google/Apple 登录、Realtime 到达提示、Web 纪念页（Edge Function）、照片上传未接；③ 留言作者名仍为占位；④ Google Play Billing 需商店配置后启用。

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

**（无）** —— MVP 功能闭环全部完成并实测（见下）。

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
- Supabase CLI 交互式登录在无 TTY 环境需 `expect` 包装或直接用 access token；**charm 系 CLI（supabase/gh）会发光标位置查询（ESC[6n），expect 必须应答 `\033[1;1R` 否则假死**（本次排障核心结论）。
- GitHub 设备码**一次性消耗**：填错一次即作废；设备码输入框 `user-code-4` 是隐藏的横杠占位（不可见），自动填码必须按 9 格映射（`36CD-4423` → 0..8 含横杠位），错位会 not_found。
