# 海外家谱树 App · 整体开发规划

> 目标市场：海外（优先 Google Play，验证后上架 App Store）
> 技术选型：Flutter（前端） + Supabase（后端，先用免费层）
> 对标产品：FamilySearch Tree、Quick Family Tree（Digital Gene）
> 文档版本：v1.0

---

## 一、结论先行

两款对标产品都存在**明显且可被小团队攻破的短板**，这给了我们机会：

| 竞品 | 核心短板 | 我们的机会 |
|---|---|---|
| FamilySearch Tree | 强制登录、依赖巨型公共树、UI 复杂难用、缩放/拖拽频繁误触、同步失败、崩溃 | **本地优先 + 免登录可用**，交互轻快，树视图手势体验做到顺滑 |
| Quick Family Tree | 无云同步、无 GEDCOM、无 PDF、导出的 `.ftz` 跨设备读不了、无返回/主菜单按钮、协作靠手发文件 | **自动云同步 + GEDCOM 导入导出 + PDF/图片导出 + 真正的多人协作** |

**一句话定位**：*一个免注册就能用、离线也能画、会说你的语言、还能为逝去亲人点一盏灯的现代家族树 App。*

三个关键差异化：
1. **本地优先（Local-first）** —— 两款竞品都没做好（一个云端强依赖、一个根本没有云），也是个人开发者唯一能靠体验打赢的战场。
2. **首版即原生多语言** —— 两款竞品对非英语用户的体验都一般，而我们靠"按地区自动匹配 + 文化适配"吃下西班牙语、葡语、日语等巨大市场。
3. **缅怀纪念（Memorial）** —— 两款竞品**完全空白**。家谱的情感终点不是"记录"，是"纪念"。这是我们最强的情感护城河与付费抓手。

---

## 二、竞品调研：FamilySearch Tree

### 2.1 基础数据（Google Play，截至 2026-10）

| 指标 | 数值 |
|---|---|
| 包名 | `org.familysearch.mobile` |
| 开发者 | FamilySearch International（美国盐湖城，非营利组织） |
| 分类 | Books & Reference |
| 评分 | **3.8 星**（Top 概览 53.5K 条评价；评分区显示 48.3K 条） |
| 下载量 | **10M+** |
| 最近更新 | 2026-10-08 |
| 商业化 | 免费，无广告（教会背景的非营利项目） |

**近期评分分布（抽样）**：5★ 约 50%，4★ 约 9%，3★ 约 10%，2★ 约 4%，**1★ 约 27%**。
> 27% 的 1 星是一个极高的数字，说明有相当规模的用户被"卡住"了。这是我们最大的机会窗口。

### 2.2 功能全景

**A. 建树与人物档案**
- 在 App 内直接查找/添加家庭成员
- 添加已故亲属后，FamilySearch 会自动去其数据库匹配该人物
- 人物档案支持：生平事件（生/卒/婚）、照片、故事、音频录音
- 添加来源（Source）佐证信息正确性
- 最近访问人物快速引用（用户好评点：解决重复添加问题）

**B. 发现与记录**
- 数十亿条历史档案检索（出生/死亡证明等）
- "Record Hints" 自动提示可补充的档案
- 地图视图：在地图上展示祖先一生关键事件发生的地点
- 家族故事/文档/照片/录音浏览

**C. 协作与社交**
- 全球统一的公共家族树（crowd-sourced pedigree）
- 与其他 FamilySearch 用户站内消息沟通
- 查看/编辑他人录入的祖先信息
- 发现附近同样开着 App 的亲友关系（新功能）
- Labs 实验功能入口

**D. 其他**
- 支持 Accessibility、稳定性持续改进
- 搜索支持 Place / Genealogies 等新维度

### 2.3 用户好评（值得抄的点）

- ✅ 能自动把已故亲属关联到海量历史档案，成就感强
- ✅ "最近人物"选择器避免重复建人（用户专门写长评夸）
- ✅ 能发现"我和哪些名人是远房表亲"——**社交裂变点，非常适合做病毒传播**
- ✅ 免费且数据库巨大

### 2.4 用户差评（必须规避 / 可攻击的痛点）

| # | 问题 | 原文要点 | 我们的对策 |
|---|---|---|---|
| 1 | **树视图手势灾难** | 放大后想拖动树，手指一碰就打开人物档案；缩小又看不清名字。"Ancestry 就做得很好" | 自研手势层：拖动阈值 + 长按/双击才进详情；小尺寸下显示头像+缩写 |
| 2 | **记忆（Memories）同步失败** | 上传 4 周的照片都没同步到服务器，分享给家人看不到 | 上传队列可见 + 失败重试 + 状态徽标（已同步/待上传/失败） |
| 3 | **强制反复登录** | "love this app. please let me on again" —— 频繁被踢出登录 | 免登录可用；登录后长期会话 + 生物识别解锁 |
| 4 | **崩溃 / "Something went wrong"** | 移动端频繁报错，无法访问 | 崩溃兜底页 + 离线可用（云挂了也能看树） |
| 5 | **弹窗套弹窗** | "too many screens popping up… 看不见自己在打什么" | 严格单栈导航，编辑用底部全屏 Sheet，禁止弹窗叠弹窗 |
| 6 | **人机验证骚扰** | "keeps going to their website and asking to prove I'm human" | 不做强制 reCAPTCHA；用 Supabase Auth 无感登录 |
| 7 | **更新后更难用** | 用户对改版怨气很大 | 建立"设置 → 回到旧版布局"开关；大改版走 Labs 开关 |
| 8 | **导航找不到"首页"** | 移动端找不到 Home 入口 | 底部 Tab 常驻：树 / 人物 / 发现 / 我的 |

---

## 三、竞品调研：Quick Family Tree（Digital Gene）

### 3.1 基础数据

| 指标 | 数值 |
|---|---|
| 包名 | `com.digitalgene.familytree` |
| 应用名 | Quick Family Tree |
| 开发者 | Digital Gene / PLUS INC.（日本京都） |
| 分类 | Lifestyle |
| 评分 | **4.1 星**，约 6.59K 条评价 |
| 下载量 | 1M+（官网宣称 2M+） |
| 商业化 | **免费 + 含广告**，官方明确"暂无付费去广告版" |
| 最近更新 | 2026-08-06（支持 Android 16、稳定性修复） |

### 3.2 功能全景

- **免注册即可使用**，App 内无任何付费服务
- 点选即可添加父母 / 子女 / 配偶
- 兄弟姐妹显示顺序可拖拽调整
- **焦点人物居中**：选中某人后视图自动重构，把 TA 放中心 → 复杂家谱也能看清（这是它的核心卖点，也是 4.1 分的主要来源）
- 支持创建**多个家谱**（可做历史人物、小说人物关系图）
- 支持上传照片作为人物头像
- 支持同性配偶（初始异性，注册后可改）
- 数据**仅存本地**，完全离线可用
- 导入/导出备份（自研 `.ftz` 格式），实测兼容 Google Drive / 邮件 / Dropbox；Facebook / WhatsApp / LINE 收发有报告失败
- 导出的图像可自由用于商业/web 发布

### 3.3 明确不支持（官方 FAQ 原话）

- ❌ 无 PC（Windows/Mac）版本
- ❌ 不支持合并多个家谱
- ❌ **不支持 PDF 导出**
- ❌ **不支持 GEDCOM 格式**
- ❌ 不能 App 内直接打印（只能截图）
- ❌ 不同时显示父系+母系祖先
- ❌ 无多设备自动同步（只能导出文件）
- ❌ 孩子只能挂在"夫妻"之间（不想显示配偶得先加临时配偶）
- ❌ 无付费去广告版（只能看广告）

### 3.4 用户差评（必须规避 / 可攻击的痛点）

| # | 问题 | 原文要点 | 我们的对策 |
|---|---|---|---|
| 1 | **无云同步** | 分享给兄弟后，兄弟加的人只有他自己能看到，创建者也看不到，除非再发一次文件 | **核心卖点**：实时/准实时云同步 + 协作链接邀请 |
| 2 | **导出格式封闭** | 导出 `.ftz`，另一台设备装了同款 App 也读不出来 | 导出 **GEDCOM 5.5.1 / 7.0**（行业标准）+ 自家 JSON；导入兼容 GEDCOM |
| 3 | **不能导出 PDF** | 用户明确说"修好就给 5 星" | PDF / PNG / SVG 一键导出（含海报级打印尺寸） |
| 4 | **无返回 / 主菜单按钮** | 必须完全退出 App 才能回主菜单 | 标准 AppBar 返回 + 底部 Tab |
| 5 | **UI Bug：按钮被状态栏遮挡** | Mi 9T 上设置图标被状态栏盖住无法点击 | 全面使用 SafeArea + 刘海/打孔屏适配测试矩阵 |
| 6 | **含广告且无去广告选项** | 官方明确不考虑付费版 | 免费版轻量（不打断式广告）+ 低价 Pro 去广告 |

---

## 四、痛点汇总 → 产品机会点

把两款产品的差评合并去重，得到 **10 个确定性机会点**（按投入产出比排序）：

| 优先级 | 机会点 | 攻击对象 | 实现难度 |
|---|---|---|---|
| P0 | 多设备自动同步 + 协作 | Quick FT | 中（Supabase Realtime/轮询） |
| P0 | GEDCOM 导入 / 导出 | Quick FT | 中（解析器约 3-5 天） |
| P0 | PDF / 高清图导出 | Quick FT | 低-中 |
| P0 | 免注册即可用，本地优先 | FamilySearch | 低（架构设计） |
| **P0** | **缅怀纪念（献花/点烛/上香/留言）** | **两者皆空白** | **中（新模块，约 2.5 周）** |
| **P0** | **首版 12 种语言 + 地区自动匹配** | **两者本地化都一般** | **中（横切改造，约 2 周）** |
| P1 | 树视图手势（缩放拖拽不误触） | FamilySearch | 中-高（自研渲染层） |
| P1 | 焦点人物居中 + 多树管理 | 抄 Quick FT 优点 | 中 |
| P1 | 上传/同步状态可视化 + 离线队列 | FamilySearch | 中 |
| P2 | 名人亲戚 / 家族地图 / 时间轴 | FamilySearch | 高（需外部数据源） |
| P2 | 档案自动匹配提示 | FamilySearch | 高（需付费数据 API） |

> ⚠️ P2 的历史档案数据需要付费接入（如 FamilySearch API、Findmypast 等），
> **个人开发者初期不要碰**。先用"手动录入 + 结构化"跑通，等有收入再考虑。

> 💡 **缅怀 + 多语言是本次新增的两个 P0，且互相强化**：
> 缅怀是高度文化相关的行为（东亚上香、拉美万寿菊、犹太放石、欧美点烛），
> 只有配合多语言/地区适配才能真正打动用户；反过来说，
> **也只有做了多语言，才有资格吃下拉美、东亚这些"家族观念最强、竞品最薄弱"的市场。**

---

## 五、产品定位与 MVP 功能清单

### 5.1 定位

**品牌名：Lararium** · **包名：`com.ay1px.tree`**（均已定稿 · 见 11.6）
> *The shrine your family keeps.* —— 古罗马家庭供奉祖先守护神（Lares）的神龛，一次覆盖「家谱 + 缅怀」两大卖点。
> 已采「包名与品牌名解耦」策略：包名锁死可立即开工，品牌名随时可在 Play Console 改（无需发版）。
> *Keep your roots. Remember them forever.*

- 面向：**全球**普通用户（拉美、欧洲、东亚、北美并重）+ 有族谱整理需求的爱好者
- 核心场景：
  1. 家庭聚会/祭祖时补录与核对（**线下场景**）
  2. 寻根、梳理祖先脉络
  3. **缅怀逝去亲人**：献花、点烛、上香、留言
  4. 给长辈做纪念海报 / 迁移老家谱数据（GEDCOM）
- 不做：历史档案检索（早期）、DNA（完全不做）

### 5.2 MVP 功能清单（V1.0）

**P0 — 必须有**

| 模块 | 功能 | 说明 |
|---|---|---|
| 免注册 | 打开即用，数据存本地 | 安装后 30 秒内建出第一个人 |
| 人物 | 增删改查：姓名/性别/生卒日期地点/职业/备注/头像 | 支持"仅年份" "约 1900" 等模糊日期 |
| 关系 | 添加父母 / 子女 / 配偶 / 兄弟姐妹；拖拽调整顺序 | 支持多配偶、同性配偶、养父母/继父母标记 |
| 树视图 | ① 焦点人物视图（居中）② 祖先树（扇形/垂直）③ 后代树 | 默认焦点视图 |
| 多树 | 创建/切换/复制多个家谱 | |
| 本地存储 | SQLite/Drift 全量本地库 | 完全离线可用 |
| 导出 | PNG / PDF（A4 + 海报 2x）／**GEDCOM 5.5.1** | |
| 导入 | **GEDCOM** 解析导入 | 关键差异化 |
| 账号 | 可选注册（邮箱 / Google / Apple 登录） | 不登录不阻断 |
| 同步 | 登录后一键上云，多设备自动同步 | Supabase |
| 协作 | 生成邀请链接，读/写两种权限 | |
| **多语言** | **首版 12 种语言**，按设备语言/地区自动匹配默认，支持应用内手动切换 | 详见 5.3 |
| **缅怀纪念** | 已故人物可**献花 / 点烛 / 上香 / 祈福 / 留言**，支持匿名、忌日提醒、纪念墙、分享纪念页 | 详见 5.4 |
| 基础设置 | 深浅色、字号、默认语言、缅怀主题偏好 | |

**P1 — 第二个版本**

- 家族相册 / 人物故事（富文本）
- 时间轴（Life Timeline）
- 家族地图（事件地点打点，用免费地图或静态图）
- 生日/忌日提醒（本地通知）
- 变更历史（谁改了什么，可回滚）
- 重复人物检测与合并
- 关系计算器（"我和他是什么关系"）
- 搜索（跨树全文）
- 缅怀增强：语音留言、虚拟供品、纪念视频（照片轮播 + 音乐）
- 第二/三批语言（ru/nl/pl/tr/ar/hi/id/vi/th 等）

**P2 — 后期**

- 档案提示接入（付费 API）
- 家族树网页分享页（Supabase Edge Function 渲染）
- 缅怀纪念页公开分享（Web 版，利于裂变）
- 打印邮寄服务（第三方 API，可做变现）
- 北欧语系（sv/nb/da/fi，家谱需求高但市场小）

### 5.3 国际化与多语言策略（首版即做）

#### 5.3.1 语言清单

**Tier 1 — V1.0 首版必做（12 种，覆盖海外约 75-80% 潜在用户）**

| # | 语言 | code | 主要市场 | 优先级理由 |
|---|---|---|---|---|
| 1 | English | `en` | 美/英/加/澳 | 兜底默认 |
| 2 | Spanish | `es` | 西班牙 + 拉美（约 5 亿） | **最大增量市场**，拉美家族观念极强 |
| 3 | Portuguese | `pt` | 巴西（2.1 亿） | 单一国家大市场，竞品本地化差 |
| 4 | French | `fr` | 法国/加拿大/西非 | |
| 5 | German | `de` | 德国/奥地利/瑞士 | 付费能力最强 |
| 6 | Italian | `it` | 意大利 | 家族文化强 |
| 7 | 日本語 | `ja` | 日本 | 付费强；Quick FT 是日本公司，证明日本有需求 |
| 8 | 한국어 | `ko` | 韩国 | |
| 9 | 简体中文 | `zh-Hans` | 海外华人/新马 | **家谱需求最高的群体之一** |
| 10 | 繁體中文 | `zh-Hant` | 港台 + 海外华人社区 | |
| 11 | Russian | `ru` | 俄罗斯/东欧 | |
| 12 | Dutch | `nl` | 荷兰/比利时 | 英语接受度高但本地化加分 |

**Tier 2 — V1.1 补（8 种，按数据表现决定顺序）**
`pl` 波兰、`tr` 土耳其、`ar` 阿拉伯（⚠️ 需 RTL）、`hi` 印地、`id` 印尼、`vi` 越南、`th` 泰语、`sv` 瑞典

**Tier 3 — V1.2+**
`nb/da/fi` 北欧、`he` 希伯来（RTL）、`el` 希腊、`cs` 捷克、`ro` 罗马尼亚、`uk` 乌克兰

> 💰 **成本建议**：不要一次上 30 种语言。先上 12 种看 Play Console 的"按国家/语言的安装与留存"数据，
> 哪个国家增长快就补哪个语言。多语言不是"越多越好"，而是"翻译质量不能拖后腿"。

#### 5.3.2 默认语言自动选择逻辑

```
1. 用户在设置里手动选过？  → ✅ 用用户选择（最高优先级，持久化到本地）
2. 未曾选择               → 读取系统语言列表 PlatformDispatcher.instance.locales
3. 逐个匹配 supportedLocales：
     a. 先精确匹配 languageCode + countryCode（如 pt_BR → pt）
     b. 再只匹配 languageCode（如 de_AT → de）
     c. 中文特殊处理：
          zh + (CN|SG|MY) 或 script=Hans → zh-Hans
          zh + (TW|HK|MO) 或 script=Hant → zh-Hant
          zh 无 script/country 信息      → zh-Hans（简体为主流）
4. 系统语言列表中**任意一个**能匹配即停止（用户可能设了 zh 为第二语言）
5. 全部无法匹配 → 兜底 en
```

**关键细节：**
- 用 `locales`（复数）而不是 `locale`（单数），遍历用户设置的**完整语言偏好列表**
- 首次启动确定语言后写入本地；用户后续在设置中切换 → 立即生效并持久化
- 提供"跟随系统 / 强制指定"三态开关（跟随 / 具体语言）
- 应用内语言切换**不需要重启**（Riverpod + `locale` 状态驱动 `MaterialApp.locale`）

#### 5.3.3 翻译工作流（个人开发者低成本方案）

```
① 英文 ARB 作为唯一真源 app_en.arb
        ↓
② DeepL / Google Translate 批量机翻生成各语言 ARB
        ↓
③ 人工校对优先级排序：
     P0 必校：商店标题/描述、引导页、缅怀页、付费页、错误提示
     P1 抽查：主流程（建人/关系/导出）
     P2 机翻即可：设置项、长说明
        ↓
④ 校对方式（成本由低到高）：
     a. 自己懂的语言自己校
     b. Fiverr / Upwork 找母语者，$20-60/语言（12 语种约 $400-700）
     c. Reddit r/translator 或对应语种 Subreddit 求助（免费，但慢）
        ↓
⑤ CI 检查：新增 key 必须同步到所有语言，缺失则 fallback 英文并告警
```

> ⚠️ **Google Play 商店详情也要做多语言**（Play 支持为每个语言单独上传标题/简介/截图）。
> 这对 ASO 的本地市场转化率提升非常明显，成本却几乎为零 —— 优先级甚至高于 App 内翻译校对。

---

### 5.4 缅怀纪念功能（Memorial）—— 核心情感差异化

> 两款竞品在这个方向**完全空白**。FamilySearch 有 "Memories"（照片/故事/音频）但偏资料归档；
> Quick Family Tree 完全没有。我们要做的是**"仪式感 + 情感表达 + 家族共祭"**。

#### 5.4.1 产品理念

家谱 App 的终点不是把人"存进数据库"，而是**让生者与逝者保持连接**。
数据会沉淀，情感会流失——缅怀功能把一次性的"录入"变成**可以反复回来的行为**，
这是留存率（Retention）最强的一根钩子。

#### 5.4.2 功能清单

**入口设计**
| 入口 | 形态 |
|---|---|
| 人物详情页 | 顶部「Memorial 纪念卡」：头像（黑白化处理）+ 生卒年 + "In Loving Memory" + 鲜花/蜡烛计数 |
| 树视图 | 已故人物节点加**悼念标记**（小花图标 / 头像去饱和 + 暗色描边），一眼可辨 |
| 纪念墙（Memorial Wall） | 独立 Tab：按"最近被缅怀"排序，展示树内所有已故人物卡片 |
| 忌日提醒 | 本地通知："今天是 Mary 逝世 3 周年，去点一支蜡烛" |
| 分享 | 生成纪念页链接（Web），家族成员无需装 App 也能献花留言 |

**缅怀动作（可重复，累计计数）**

| 动作 | 说明 | 文化适配 |
|---|---|---|
| 🌹 献花 | 玫瑰/百合/康乃馨/菊花/万寿菊 | 通用 |
| 🕯️ 点烛 | 点亮蜡烛，可选"长明烛"（Pro） | 基督教/天主教/拉美亡灵节 |
| 🪔 上香 | 香炉 + 青烟动画 | 东亚（中日韩越）+ 佛教 |
| 🙏 祈福 / 祷告 | 文字祷词模板可选 | 通用 / 基督教 Dua（伊斯兰） |
| 🪨 放石（Stone） | 犹太墓碑放石传统 | 犹太教 |
| 🪔 点油灯（Diya） | 印度教排灯节 | 印度 |
| 💬 留言 | 文字/语音/照片 | 通用 |
| 🕊️ 放飞 | 白鸽/气球/孔明灯 | 通用 |

**留言系统**
- 支持署名 / 匿名
- 点赞、排序（最新 / 最感动）
- **举报 + 折叠**（UGC 必备，见 5.4.5 合规）
- 树管理员可删除、置顶
- 支持多语言留言（按留言语言显示，可一键机翻）

**仪式感与动画（决定这个功能能不能"打动人"）**
- 献花：花瓣飘落 + 花束渐显
- 点烛：火苗点亮 + 光晕扩散 + 轻微摇曳
- 上香：香烟袅袅上升粒子效果
- 音效开关（默认关，避免公共场合尴尬）
- **实时感**：家人的献花通过 Realtime 实时出现动画 + 提示"John 刚刚献了一束花"
- 节日主题皮肤：清明节（素白/柳枝）、万圣节/诸圣节（暖橙烛光）、亡灵节（万寿菊橙黄）、盂兰盆节（灯笼）

**纪念页（分享与裂变）**
- Web 纪念页（Supabase Edge Function + 静态渲染）：逝者照片 + 生平 + 留言墙 + "献一束花"按钮
- 可直接分享到 WhatsApp / Facebook / Messenger（**正好补上 Quick FT 在社交分享上的短板**）
- 扫码分享：家庭聚会/葬礼现场扫码即可参与 → **线下场景是极强的自然增长点**

#### 5.4.3 文化适配（重要）

缅怀是**高度文化相关**的行为，做错了会冒犯用户。

**已定策略：按地区自动推荐 + 用户可自选一次（也可随时改）**

##### A. 主题包清单

| 主题包 | 默认道具 | 视觉基调 |
|---|---|---|
| `western` | 鲜花、蜡烛、留言 | 素雅暖白 |
| `east_asian` | **上香**、献花、鞠躬、留言 | 素白 + 青烟 |
| `latin` | **万寿菊**、蜡烛、照片祭坛 | 橙黄 + 彩色剪纸 |
| `jewish` | **放石**、长明烛 | 石青 + 白 |
| `hindu` | 花环、**油灯 Diya** | 暖金 |
| `islamic` | **仅祈祷与留言**（不出示蜡烛/香/花圈，尊重教义） | 青绿 + 几何纹 |
| `secular` | 鲜花、点灯、留言 | 中性无宗教符号 |

##### B. 地区 → 主题包推荐映射（预选值，非强制）

```
设备 locale / 地区              预选主题包
─────────────────────────────────────────
es-MX, es-GT/PE/CO/BO/EC...  →  latin       (拉美亡灵节文化圈)
es-ES, es-AR/UY/CL           →  western     (欧洲化天主教)
pt-BR, pt-PT                 →  western
ja, ko, zh-Hans, zh-Hant, vi →  east_asian
iw / he, (IL)                →  jewish
hi, bn, ta, mr, (IN)         →  hindu
ar, fa, id, ms, tr           →  islamic
其他 / 无法判定               →  secular
```

> ⚠️ **语言 ≠ 宗教**。以上仅作"首次预选值"，且**首次必弹一次性确认层**让用户看到并有机会改。
> 阿拉伯语/土耳其语/印尼语用户中有大量基督徒，因此 `secular` 与 `western` 必须在同一屏可见可选，
> 绝不能只给一个伊斯兰主题。

##### C. 首次选择流程（关键 UX）

```
用户首次进入某位逝者的缅怀页
        ↓
┌──────────────────────────────────────┐
│  选择缅怀方式                          │
│  （可按家族传统或个人喜好随时更改）       │
│                                        │
│  ● 中式（上香 · 献花）      ← 已推荐     │
│  ○ 西式（鲜花 · 点烛）                  │
│  ○ 拉美（万寿菊 · 蜡烛）                │
│  ○ 犹太（放石 · 长明烛）                │
│  ○ 印度（花环 · 油灯）                  │
│  ○ 伊斯兰（祈祷 · 留言）                │
│  ○ 中性（不含宗教符号）                 │
│                                        │
│  [ 使用推荐 ]        [ 查看全部 ]       │
└──────────────────────────────────────┘
        ↓
写入 memorial_profiles.theme（**人物级**，不同先人可有不同主题）
```

**设计要点：**
1. **只弹一次，但可改**：选择后写入该人物的 `theme`；纪念页右上角「⚙ 更改缅怀方式」随时可换
2. **推荐项默认选中且带「已推荐」标签**，用户直接点「使用推荐」即可 → 大多数用户零操作成本
3. **是人物级而非全局级**：中式爷爷 + 西式外祖父可以并存，符合真实家庭
4. **全局设置兜底**：`设置 → 缅怀 → 默认缅怀方式：跟随地区推荐 / 固定为 XXX`，作用于之后新建的纪念页
5. **主题包只影响"默认展示哪些道具 + 视觉基调"，不锁死道具**：用户在任何主题下都能从「全部道具」里找到上香/点烛等等，只是排序不同

##### D. 其他文化适配细节
- **宗教符号谨慎**：十字架、佛号、万寿菊骷髅等只在对应主题包内出现，且 `设置 → 缅怀 → 隐藏宗教符号` 可全局关闭
- **文案本地化**：`In Loving Memory` / `En memoria de` / `Em memória de` / `謹以此紀念` / `追悼`
- **忌日计算**：按当地历法显示（公历为主；V2 可考虑农历/佛历，成本高先不做）
- **节日主题皮肤**：清明（素白柳枝）、盂兰盆（灯笼）、诸圣节（暖橙烛光）、亡灵节（万寿菊橙黄）

#### 5.4.4 商业化设计

**已定额度：免费版献花 1 朵/天**（其余动作对齐，均为每日 1 次）

| 缅怀动作 | 免费版 | Pro |
|---|---|---|
| 🌹 献花 | **1 朵/天** | 无限 |
| 🕯️ 点烛 | 1 支/天 | 无限 + 长明烛（永久展示） |
| 🪔 上香 | 1 炷/天 | 无限 |
| 🙏 祈福 | 1 次/天 | 无限 |
| 💬 文字留言 | 3 条/天 | 无限 |
| 🔊 语音留言 | ❌ | ✅ |
| 💐 高级花束 / 花圈 | ❌ | ✅ |
| 🎞️ 纪念视频（照片轮播+音乐） | ❌ | ✅ |
| 🎨 纪念页自定义背景/音乐 | ❌ | ✅ |

**额度口径**：按「用户 × 自然日」计算（UTC+用户本地时区重置），**不按人物**——
即一天内给 3 位先人献花，也只能献 1 朵。这个口径更利于转化，但必须配下面两条豁免，否则会招差评。

**两条必须做的防差评设计：**

1. **忌日当天豁免** —— 某位逝者的忌日（含周年）当天，该人物的各类动作额度 **+1**。
   > 场景：爷爷忌日到了，免费用户却因额度用完献不了花 → 这是**最容易爆发的差评点**，必须豁免。
2. **额度耗尽时的提示必须温和且给出出路**：
   ```
   ❌ 错误文案："今日次数已用完，升级 Pro 继续"
   ✅ 正确文案："今天已经为 TA 献过一束花了 🌹
                 明天再来，或写一段想说的话（留言还可用）
                 ─────────────────────
                 想要更多纪念方式？看看 Pro →"
   ```
   原则：**免费用户永远有一条情感出口**（留言/查看/翻看旧留言），绝不能出现"什么都不让做"的死路。

> 📊 **数据驱动**：上线后重点盯"额度耗尽"事件的后续留存与评论情绪。
> 若 1 星评论中出现"太抠门/too limited"，**第一优先级调整为 2 朵/天**（改配置即可，无需发版）。
> 建议把这个数字做成**服务端可配参数**（`remote_config`），随时调整不用发版。

> ⚠️ **Google Play 合规红线**：虚拟商品内购**必须走 Google Play Billing**，不能引导外部支付。
> 好消息：年收入 100 万美元以下适用 **15% 优惠费率**（Google Play 小型企业计划）。
> 另外，"为逝者献花"这类情感型内购，**文案上必须避免"付费才能表达孝心/爱"的观感**，
> 建议措辞为"支持开发者，解锁更多纪念方式"，否则容易招差评。

#### 5.4.5 合规与风险（必做，否则上架和运营都会出事）

| 风险 | 对策 |
|---|---|
| 🔴 **UGC 留言滥用**（辱骂、政治、广告） | ① 留言本地敏感词过滤 + 云端二次过滤；② 一键举报 + 24h 处理；③ 默认仅家族成员可见，公开链接需管理员开启；④ 树管理员可一键关闭该人物的留言 |
| 🔴 Google Play 审核 | 商店"用户生成内容"问卷如实填写；提供举报入口与屏蔽用户功能；隐私政策写明 UGC 处理规则 |
| 🟡 **对在世人物误操作** | `is_living = true` 或 `death_date` 为空的人物**强制隐藏缅怀入口**；批量操作时二次确认 |
| 🟡 未成年人相关 | 若逝者去世时为未成年，纪念页默认仅家族可见 |
| 🟡 数据隐私 | 非家族成员通过公开链接访问时，逝者生平仅显示姓名/生卒年，不显示其他亲属信息 |
| 🟢 刷量 | 同一用户对同一人物同类动作 N 秒冷却；每日全局上限；异常流量告警 |

### 5.5 明确不做（避免踩坑）

- ❌ DNA 相关（合规风险高、成本极高）
- ❌ 自动爬取公共家谱数据（法律与审核风险）
- ❌ 强制注册 / 强制社交
- ❌ 缅怀功能中的**现金打赏 / 捐赠**（涉金融合规与宗教敏感，风险远大于收益）
- ❌ 自动接入第三方讣告/殡葬服务数据（隐私与合规风险）

---

## 六、技术架构

### 6.1 总体架构

```
┌─────────────────────────────────────────────────┐
│  Flutter App (iOS / Android / 后期 Web)          │
│  ┌───────────┐ ┌───────────┐ ┌───────────────┐  │
│  │ UI Layer  │ │ Tree 引擎 │ │ Sync Engine   │  │
│  │ (Riverpod)│ │(CustomPaint)│ │ (增量/冲突) │  │
│  └─────┬─────┘ └───────────┘ └───────┬───────┘  │
│        └──────────────┬──────────────┘          │
│              ┌────────▼────────┐                │
│              │ Drift (SQLite)  │ ← 唯一数据源   │
│              │  + 同步元数据表  │                │
│              └────────┬────────┘                │
└───────────────────────┼─────────────────────────┘
                        │ 网络可用时
              ┌─────────▼──────────┐
              │     Supabase       │
              │ Postgres + RLS     │
              │ Auth / Storage     │
              │ Realtime(可选)     │
              └────────────────────┘
```

**核心原则：本地 SQLite 是唯一数据源，云只是副本。** 这直接解决了：
- FamilySearch 的"云挂了就用不了"问题
- Quick Family Tree 的"根本没云"问题

### 6.2 前端技术栈（Flutter）

| 用途 | 选型 | 理由 |
|---|---|---|
| 状态管理 | **Riverpod 2.x** | 编译安全、易测试 |
| 路由 | **go_router** | 深链（邀请链接）友好 |
| 本地库 | **Drift**（SQLite） | 类型安全、有迁移工具、性能好 |
| 树渲染 | **自研 CustomPaint 引擎**（参考 `graphview` 的 Buchheim–Walker 实现） | 竞品最大的体验痛点就在这一层，不能外包给通用库 |
| 手势 | `InteractiveViewer` 二次封装 + 自定义拖动阈值 | 解决 FS 误触问题 |
| 依赖注入 | `get_it` 或 Riverpod Provider | |
| 序列化 | `freezed` + `json_serializable` | |
| 网络 | `supabase_flutter` | |
| 图片 | `cached_network_image` + 本地压缩 | |
| PDF 导出 | 自绘 `pdf` 包（Dart 原生） | 跨平台一致，不用 native 依赖 |
| GEDCOM | 自研解析器 | 开源库质量参差，自己写更可控 |
| 崩溃监控 | Sentry（免费额度）或 Firebase Crashlytics | 必须有 |
| 分析 | PostHog（免费 1M events/月）或 Supabase 自建 | |

> **为什么不直接用 `graphview`：**
> 它适合通用图，但家谱树需要处理"配偶节点并列、子女挂在配偶连线下、多父母、折叠子树"等特有规则，
> 且 5000+ 节点时帧率会掉。V1 可用它快速出原型，**V1.5 必须自研替换**。

### 6.3 数据模型（Postgres / 本地 SQLite 同构）

设计上兼容 **GEDCOM 5.5.1 / GEDCOM 7**，保证导入导出无损。

```sql
-- 家谱（一个用户可有多个）
trees (id uuid pk, name, description, owner_id, cover_person_id,
       visibility, created_at, updated_at, deleted_at)

-- 树成员与权限
tree_members (tree_id, user_id, role  -- owner|editor|viewer
              invited_by, joined_at, PRIMARY KEY(tree_id, user_id))

-- 人物
persons (
  id uuid pk, tree_id, gedcom_id text,       -- 对应 GEDCOM 的 @I1@
  given_name, surname, nickname, prefix, suffix,
  gender  -- male|female|other|unknown
  birth_date, birth_date_precision,          -- day|month|year|approx|range
  birth_place, death_date, death_place,
  is_living bool,                            -- 在世人隐私脱敏
  occupation, note, avatar_media_id,
  created_by, updated_at, deleted_at,
  client_updated_at timestamptz,             -- 冲突解决
  revision int default 1
)

-- 核心家庭（配偶/伴侣单元）—— GEDCOM 的 FAM
families (
  id uuid pk, tree_id, gedcom_id,
  partner1_id, partner2_id,                  -- 可为 null（单亲家庭）
  relation_type  -- married|unmarried|divorced|partner
  marriage_date, marriage_place, divorce_date,
  sort_order, deleted_at, client_updated_at, revision
)

-- 子女归属（一个孩子可属于多个家庭：亲生 + 收养）
family_children (
  family_id, person_id, sort_order,
  pedigree  -- birth|adopted|foster|step
  PRIMARY KEY(family_id, person_id)
)

-- 通用事件表（比写死字段更灵活，对齐 GEDCOM）
events (
  id, person_id NULL, family_id NULL,
  type  -- BIRT|DEAT|BURI|CHR|GRAD|OCCU|RESI|IMMI|custom
  date_text, date_from, date_to, date_precision,
  place_text, latitude, longitude,
  description, sort_order, deleted_at
)

-- 媒体
media (id, tree_id, person_id NULL, family_id NULL, event_id NULL,
       kind  -- photo|document|audio|video
       storage_path, local_path, mime, width, height, bytes,
       caption, is_primary, upload_state, deleted_at)

-- 来源引用（GEDCOM SOUR，先做轻量版）
sources (id, tree_id, title, author, publisher, url, repository, note)
citations (id, source_id, person_id NULL, family_id NULL, event_id NULL, page, quote)

-- 邀请
invites (id, tree_id, code, role, expires_at, max_uses, used_count, created_by)

-- 同步元数据
sync_state (table_name, last_pulled_at, last_pushed_seq)
outbox (id, table_name, row_id, op  -- insert|update|delete
        payload jsonb, created_at, retry_count, last_error)
```

**RLS 策略要点**：所有表开 RLS，通过 `tree_members` 做权限判断，用 `SECURITY DEFINER` 函数避免递归 RLS 问题。

### 6.4 同步策略（关键）

采用 **增量拉取 + 本地 outbox 推送 + LWW 冲突解决**：

1. **推送**：所有本地写操作先落 SQLite，同时写一条 `outbox` 记录 → 后台任务批量推 Supabase
2. **拉取**：按 `updated_at > last_pulled_at` 增量拉，服务端删除用 `deleted_at` 软删同步
3. **冲突**：字段级 **Last-Write-Wins**（比较 `client_updated_at`），并在 UI 上给出"该人物有冲突"提示 + 手动选择版本
4. **实时**：V1 用「前台轮询 10s + 推送后即时拉取」；V1.5 再接 Supabase Realtime（免费 200 并发连接够初期用）
5. **离线**：断网时一切正常，`outbox` 队列积压，恢复后自动补偿，UI 顶部显示"待同步 N 项"

> 这直接解决 Quick Family Tree 差评 #1（"兄弟加的人我看不到"）。

### 6.5 Supabase 免费额度评估

| 资源 | Free 额度 | 我们的估算用量 | 结论 |
|---|---|---|---|
| 数据库 | 500 MB | 1 人约 30-80 KB（含媒体元数据）；**1000 活跃用户 ≈ 50-80 MB** | ✅ 够跑到 ~5000 用户 |
| 文件存储 | 1 GB | 头像压缩到 ≤200KB，**约 5000 张** | ⚠️ 最先爆的瓶颈 |
| 出网流量 | 5 GB/月 + 5 GB 缓存 | 同步是增量，单用户月约 5-20 MB → **约 500-1000 MAU** | ⚠️ 关键瓶颈 |
| Auth MAU | 50,000 | 远超需求 | ✅ |
| Edge Functions | 50 万次/月 | 够 | ✅ |
| Realtime | 200 并发 / 200 万消息 | 初期够 | ✅ |
| 活跃项目数 | **2 个** | 1 个 prod + 1 个 staging 刚好 | ⚠️ 需规划 |
| **不活跃暂停** | **1 周无活动自动暂停** | 🔴 **生产环境致命风险** | 🚨 必须处理 |

**免费层三大风险与对策：**

| 风险 | 对策 |
|---|---|
| 🔴 1 周不活跃自动暂停（生产库停机） | ① 用 GitHub Actions 定时任务每天 ping 一次（免费）；② **正式发布即升级 Pro $25/月**，把免费层只当开发环境 |
| ⚠️ 存储 1 GB 很快满 | 客户端上传前**强制压缩**（头像 ≤ 200KB、长边 ≤ 1024px）；原图不进云，只本地存 |
| ⚠️ 5 GB 出网 | 同步走**增量**（只传变更行）+ 响应 gzip + 图片走 CDN 缓存 |

**成本演进曲线（预估）**：
```
0 – 1,000 MAU    ：Free（开发期）或 Pro $25/月（发布后建议直接上）
1,000 – 10,000   ：Pro $25/月 + 存储超额（$0.021/GB）≈ $30-50/月
10,000 – 50,000  ：Pro + 更多额度 ≈ $50-150/月
```
> 建议：**发布当月就上 Pro（$25/月）**。对个人开发者这是必要成本，不能为省 25 美元冒停机风险。

### 6.6 国际化技术实现

**方案：`flutter_localizations` + ARB + `flutter gen-l10n`（官方标准，类型安全）**

```
lib/l10n/
  ├── app_en.arb      ← 唯一真源
  ├── app_es.arb
  ├── app_pt.arb
  ├── ... (12 种)
  └── app_zh_Hans.arb / app_zh_Hant.arb
l10n.yaml             ← gen-l10n 配置
```

```dart
// MaterialApp 配置
return MaterialApp.router(
  locale: ref.watch(localeProvider),           // 用户手动选择或自动解析结果
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,                  // 业务文案
    GlobalMaterialLocalizations.delegate,       // Material 组件内置文案
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,        // 决定文字方向 RTL/LTR
  ],
  ...
);
```

**六个必须提前处理的坑：**

| # | 坑 | 解法 |
|---|---|---|
| 1 | **RTL 布局** | `ar`/`he` 需要 `Directionality` 翻转。**自绘的家谱树引擎必须显式支持 RTL** —— 祖先树的展开方向、连线锚点、人物卡片内边距全部要按 `TextDirection` 走。这是自研渲染层的一大工作项，**架构阶段就要把 `TextDirection` 作为参数传进布局算法，不要事后补** |
| 2 | **文本长度差异** | 德语/俄语/芬兰语比英语长 30-40%，阿拉伯语更长。**禁止写死宽度**，全部 `Flex`/`Expanded`；按钮文本允许换行；用 `Text.rich` 处理长复合句 |
| 3 | **复数规则** | 英语 2 种（one/other），俄语 3-4 种，阿拉伯语 6 种（zero/one/two/few/many/other）。用 ARB 的 ICU `plural` 语法，绝不用 `{count} items` |
| 4 | **姓名顺序** | 东亚"姓+名"、欧美"名+姓"、西班牙语"名+父姓+母姓"、匈牙利/日韩部分场景也不同。数据层已拆 `given_name`/`surname`，**显示层按 locale 决定拼接顺序，并提供"强制显示顺序"的个人设置** |
| 5 | **日期与数字** | `intl` 的 `DateFormat.yMMMd(localeName)`。家谱有大量"仅年份""约 1900""1900-1905"等模糊日期，需独立格式化逻辑而非纯 `DateFormat` |
| 6 | **字体与包体积** | 默认字体不完整覆盖 CJK/泰文/阿拉伯。方案：拉丁语系用系统字体；CJK/泰文用 `google_fonts`（按需下载）或内置 **Noto 子集**。**12 种语言不要全部内置字体，按 locale 动态加载**，否则 AAB 体积失控 |

**测试策略**
- 启用**伪语言（pseudo-locale）**：把所有文案替换成 1.4 倍长度的占位串，快速扫出所有溢出/截断
- 至少在 3 台真机上验证：`en`（LTR 短）、`de`（LTR 长）、`ar`（RTL）
- `ja`/`zh` 验证字体渲染与换行（CJK 无空格换行规则不同，需 `TextStyle.wordSpacing` 调优）

---

### 6.7 缅怀功能技术方案

**数据表设计**

```sql
-- 人物纪念档案（1:1 挂在已故人物上）
memorial_profiles (
  person_id uuid pk references persons,
  tree_id uuid,
  is_enabled bool default true,        -- is_living=true 时强制 false（触发器保证）
  theme text,                          -- 首次由地区推荐+用户确认写入，NULL=尚未选择（需弹一次选择层）
                                       -- western|east_asian|latin|jewish|hindu|islamic|secular
  theme_is_auto bool default true,     -- true=由地区推荐预选后直接确认；false=用户手动改过
  epitaph text,                        -- 墓志铭
  cover_media_id uuid,
  allow_messages bool default true,
  allow_public_link bool default false, -- 公开纪念页需管理员显式开启
  allow_anonymous bool default true,
  -- 计数冗余字段（由触发器/定时聚合维护，避免每次 count）
  flower_count int default 0,
  candle_count int default 0,
  incense_count int default 0,
  prayer_count int default 0,
  message_count int default 0,
  last_memorial_at timestamptz,
  updated_at timestamptz
)

-- 单次缅怀动作
memorial_acts (
  id uuid pk, person_id uuid, tree_id uuid,
  actor_user_id uuid, actor_name text, is_anonymous bool default false,
  kind text,          -- flower|candle|incense|prayer|stone|diya|wreath|lantern
  item_code text,     -- rose|lily|carnation|chrysanthemum|marigold|long_candle|...
  quantity int default 1,
  source text,        -- app|web
  created_at timestamptz,
  client_updated_at timestamptz
)
CREATE INDEX idx_acts_person_time ON memorial_acts(person_id, created_at DESC);

-- 留言
memorial_messages (
  id uuid pk, person_id uuid, tree_id uuid,
  author_user_id uuid, author_name text, is_anonymous bool default false,
  body text, lang text,                 -- 留言语言，便于展示"翻译"按钮
  attachment_media_id uuid,             -- 语音/图片（Pro）
  like_count int default 0,
  status text default 'visible',        -- visible|hidden|reported|deleted
  is_pinned bool default false,
  created_at timestamptz, client_updated_at timestamptz
)

-- 留言点赞 / 举报
memorial_message_likes (message_id, user_id, created_at, PRIMARY KEY(message_id, user_id))
memorial_reports (id, target_type, target_id, reason, reporter_user_id,
                  status text default 'pending', handled_at)
```

**RLS 要点**
- `memorial_profiles` / `memorial_messages`：**树成员可读**；仅树成员可写缅怀动作
- `allow_public_link = true` 时，**匿名角色（`anon`）只读**纪念页（走 `anon` key + 受限视图，只暴露姓名/生卒年/封面/留言，**不暴露其他亲属关系**）
- 留言删除：仅作者本人或 `owner/editor` 角色

**关键实现点**

| 项 | 方案 |
|---|---|
| 实时感 | Supabase Realtime 订阅 `memorial_acts`（按 `person_id` 过滤），收到新动作播放动画 + 顶部提示。**免费层 200 并发连接够用**；注意退到后台要取消订阅 |
| 计数 | 写入时由 **Postgres 触发器**增量更新 `memorial_profiles.*_count`，读取 O(1)，避免大表 count |
| 离线缅怀 | 缅怀动作同样走 **outbox 队列**（见 6.4），断网时本地先记 + 本地动画照常播放（乐观 UI），恢复后补传 |
| 防刷 + 免费额度 | ① 客户端冷却（同人同类型 10s）；② 服务端按「用户×日×动作类型」计数（免费 1 次/天，留言 3 条/天）；③ **忌日当天该人物 +1**（服务端按 `persons.death_date` 月日匹配，考虑 2/29）；④ 额度走 **服务端可配参数**（避免改数字就要发版）；⑤ Edge Function 异常检测 |
| 主题包推荐 | `resolveMemorialTheme(locale, countryCode)` 纯函数 → 预选值（映射表见 5.4.3-B）；结果只作为**首次选择弹层的默认选中项**，最终以用户确认为准并写入 `memorial_profiles.theme` |
| 额度 UX | 服务端返回 `{allowed, remaining, resetAt, isAnniversary}`，客户端据此渲染温和提示与"留言还可用"出口 |
| 动画 | 花瓣/青烟/烛焰用 **CustomPaint + 粒子系统自绘**（零依赖、无版权风险、可主题化）；复杂角色动画用 Rive / Lottie（**注意 License，LottieFiles 免费素材需署名**） |
| 音效 | `audioplayers`，默认关闭，设置页开关 |
| 忌日提醒 | `flutter_local_notifications` + `timezone`，本地计算（不依赖服务端），支持"逝世 N 周年"文案本地化 |
| Web 纪念页 | Supabase Edge Function（Deno）渲染静态 HTML + `anon` key 读受限视图；分享走 `share_plus` |
| 敏感词 | 客户端内置轻量词表（拦截+提示）+ 服务端 Edge Function 二次校验；命中 → `status='hidden'` 待人工复核 |

---

## 七、开发路线图（个人开发者，全职估算）

总计约 **18 周（4.5 个月）** 到 Google Play 首发（原 14 周 + 多语言 2 周 + 缅怀 2.5 周）；
兼职按 1.5-2 倍折算。

> ⚠️ **排期原则：多语言和缅怀不要并行塞进同一周。** 多语言是"横切所有页面"的改造，
> 缅怀是"独立新模块"，两者同时做会让调试互相污染。建议顺序：先做完多语言 → 再做缅怀。

### 阶段 0：准备（第 1 周）
- [x] ~~定名 Rootkeep（`app.rootkeep.tree`）~~ —— ⛔ **已废弃，见 11.6**
- [x] 定包名 **`com.ay1px.tree`**（Android + iOS 一致，与品牌名解耦）—— 见 11.6
- [ ] 🔴 **在 Play Console 建空壳草稿应用，实测 `com.ay1px.tree` 未被占用并占位**（包名一旦发布永久不可改，第 1 周最高优先级）
- [ ] USPTO TESS 检索 **LARARIUM**（第 9 类 + 第 42 类）+ 抢注 `lararium.com` 与社交账号
- [ ] 注册 Supabase 项目（prod / staging）
- [ ] Flutter 项目脚手架（ flavors: dev / prod ）
- [ ] **确定 12 种语言清单**，建 `l10n` 骨架 + `l10n.yaml`
- [ ] **建术语表 Glossary**（家谱术语如 pedigree/ancestor/spouse 各语言对照，保证翻译一致性）
- [ ] 设计稿/风格定调（参考 Quick FT 的简洁风 + Material 3）
- [ ] 建 GitHub 仓库 + CI（GitHub Actions 免费额度）

### 阶段 1：本地内核（第 2–5 周）★ 最核心
- [ ] Drift 数据库建模 + 迁移脚本
- [ ] Person / Family / Children CRUD 全部打通
- [ ] **树布局引擎**（Buchheim–Walker）+ CustomPaint 渲染
  - ⚠️ **布局函数签名必须接收 `TextDirection`**，为 RTL 预埋，事后补代价极大
- [ ] **焦点人物居中视图**（对标 Quick FT 卖点）
- [ ] 手势层：缩放/平移/防误触（对标 FS 差评 #1）
- [ ] 人物详情编辑页（底部 Sheet，绝不弹窗套弹窗）
- [ ] 本地多树管理
- [ ] 所有 UI 文案走 `AppLocalizations`（**不写死任何硬编码字符串**，这是后期省时间的关键）

### 阶段 2：导入导出（第 6–7 周）★ 差异化
- [ ] GEDCOM 5.5.1 解析器（含 ANSEL/UTF-8 编码处理）
- [ ] GEDCOM 导出
- [ ] PDF 导出（A4 / Letter / 海报 2x）用 `pdf` 包
  - ⚠️ PDF 内嵌字体需覆盖 CJK，导出前按当前 locale 选字体
- [ ] PNG 高清导出 + 分享
- [ ] 自家 JSON 备份（本地文件）

### 阶段 3：云与同步（第 8–10 周）
- [ ] Supabase Auth（邮箱 + Google + Apple）
- [ ] Postgres 建表 + RLS 策略 + 索引
- [ ] Outbox 同步引擎（推/拉/冲突/重试）
- [ ] 同步状态 UI（已同步 / 待同步 N 项 / 失败重试）
- [ ] 媒体上传（压缩 + 队列 + 断点）
- [ ] 邀请链接协作（读写权限）
- [ ] 删除/退出/数据导出合规入口

### 阶段 4：多语言落地（第 11–12 周）★ 新增
- [ ] 写完英文 `app_en.arb`（唯一真源）
- [ ] 机翻生成其余 11 个 ARB，跑通 `flutter gen-l10n`
- [ ] **默认语言自动选择逻辑**（系统 locales 列表匹配 + 中文简繁判定 + 兜底 en）
- [ ] 设置页：语言选择（跟随系统 / 指定语言），切换即时生效
- [ ] **姓名显示顺序按 locale** + 用户可强制覆盖
- [ ] 日期/数字/复数本地化（ICU plural、模糊日期格式）
- [ ] 字体方案落地（CJK 按需加载，控制 AAB 体积）
- [ ] **伪语言测试**扫一遍所有页面溢出；`en`/`de`/`ja` 三台真机验证
- [ ] **Google Play 商店详情 12 语言上传**（标题/简介/截图文案）
- [ ] RTL 预埋自检（Tier 2 才上 `ar`，但代码路径先走通）

### 阶段 5：缅怀纪念（第 13–15 周）★ 新增，情感护城河
- [ ] `memorial_*` 四张表 + 触发器计数 + RLS（含 `anon` 只读受限视图）
- [ ] 人物详情页纪念卡 + 树视图已故标记（头像去饱和 + 悼念图标）
- [ ] **缅怀动作**：献花 / 点烛 / 上香 / 祈福 / 留言（含匿名模式）
- [ ] **动画**：花瓣飘落、烛焰摇曳、青烟粒子（CustomPaint 自绘）
- [ ] **缅怀主题包**（7 种）+ `resolveMemorialTheme(locale, country)` 地区推荐映射（见 5.4.3-B）
- [ ] **首次选择弹层**：推荐项默认选中 + 「已推荐」标签 + 一键确认 / 查看全部（只弹一次，可随时改）
- [ ] 留言系统：点赞、排序、举报、管理员删除/置顶、敏感词过滤
- [ ] **纪念墙 Tab**：树内已故人物列表 + 最近被缅怀排序
- [ ] Realtime 订阅（"John 刚刚献了一束花"）+ 退后台取消订阅
- [ ] 忌日提醒（本地通知 + 多语言文案）
- [ ] **Web 纪念页**（Edge Function）+ 分享链接 + 扫码（线下场景）
- [ ] 免费额度：献花/点烛/上香/祈福 **各 1 次/天**、留言 3 条/天 + **忌日豁免 +1**；额度做服务端可配参数
- [ ] 额度耗尽的温和提示与"留言还可用"免费出口
- [ ] 缅怀动作接入 outbox（离线也能献花，乐观 UI）

### 阶段 6：打磨与上架（第 16–18 周）
- [ ] 深色模式、字体缩放、Accessibility（TalkBack/旁白）
- [ ] 引导页 + 示例家谱（新用户 30 秒上手，**引导页必须 12 语言齐全**）
- [ ] 空状态、错误态、离线提示
- [ ] Sentry 崩溃监控 + PostHog 埋点（含"各语言留存对比"看板）
- [ ] 隐私政策页面 + 数据安全表单 + **UGC 声明（留言功能）**
- [ ] 商店素材：图标、截图（5-8 张 × 主要语言）、宣传图、演示视频
- [ ] **Google Play 内测（Closed Testing）** → 公开测试 → 正式发布
- [ ] App Store 版本同步准备（iOS 隐私清单、签名证书）

### 阶段 7：发布后（持续）
- [ ] 每周看评论，**48 小时内回复所有评论**（Google Play 算法加分，也是两竞品做得一般的点）
- [ ] 看 Play Console「按国家/语言的转化与留存」，决定 Tier 2 补哪些语言
- [ ] V1.1：时间轴、相册、语音留言、纪念视频
- [ ] V1.2：家族地图、关系计算器、重复人物合并、Tier 2 语言
- [ ] V1.3：缅怀节日皮肤（清明/诸圣节/亡灵节/盂兰盆节）
- [ ] iOS 上架（复用 90% 代码，约 3-4 周适配 + 审核）

---

## 八、Google Play 上架合规清单（2026）

| 项 | 要求 | 状态 |
|---|---|---|
| Target API Level | 需满足 Google Play 最新要求（2026-08-31 起进一步收紧，按商店后台提示设置，通常需 target 到最近 1-2 个大版本） | ⬜ |
| **16 KB 内存页面对齐** | **2025-11-01 起新应用必须支持**（含 native so 的 Flutter App 需注意 NDK 对齐） | ⬜ |
| 上传格式 | **AAB**（Android App Bundle），非 APK | ⬜ |
| 数据安全表单 | 声明收集的数据类型（位置、个人信息、照片等）、是否加密传输、是否可申请删除 | ⬜ |
| 隐私政策 | 必须有可访问 URL | ⬜ |
| 账号删除 | 若支持注册，需提供 **应用内 + 网页端** 账号删除入口 | ⬜ |
| 分级问卷 | 内容分级（预计 Rated for 3+） | ⬜ |
| 广告声明 | 若含广告，需声明；使用 AdMob 需合规配置 | ⬜ |
| 目标受众 / 新闻类声明 | 按问卷填写 | ⬜ |
| 🔴 **UGC 声明**（缅怀留言功能） | 必须填写"用户生成内容"问卷；App 内需有**举报入口 + 屏蔽用户 + 内容审核机制**，否则极易被拒 | ⬜ |
| 🔴 **付费/订阅政策** | 虚拟纪念道具属数字商品，必须走 **Google Play Billing**；订阅需明确续费与退款说明 | ⬜ |
| 封闭测试 | 新个人开发者账号**需先跑 20 人 × 14 天封闭测试**才能申请正式发布 | ⬜ |
| 多语言商店详情 | 每个上传的语言都需提供对应语言的标题/简介/截图（机翻即可，但不可缺失或错配） | ⬜ |

> 🔴 **个人开发者最容易卡的地方**：新注册的 Play 开发者账号有"20 名测试者连续 14 天"的强制封闭测试要求。
> **建议：项目一开始就注册开发者账号（$25 一次性），越早开始跑测试期越好。**

---

## 九、商业化设计

### 免费版（Free）
- 无限人数、无限家谱、本地全部功能
- GEDCOM 导入导出 ✅（保持差异化，不要锁）
- 云同步：**1 棵树 / 200 人**
- 缅怀：献花/点烛/上香/祈福 **各 1 次/天**，留言 3 条/天（忌日当天该人物 +1）
- 底部 Banner 广告（不打断式，**绝不做插屏/开屏**）

### Pro（$2.99/月 或 $19.9/年）
- 去广告
- 无限云同步 + 无限协作成员
- PDF/海报导出无水印
- 高级树样式（配色/字体/边框）
- 家族地图、时间轴
- 变更历史与回滚
- **缅怀增强**：语音留言、高级花束/花圈、长明烛、纪念视频、纪念页自定义背景与音乐

### 变现建议
1. **先积累用户，第 3 个月再上广告** —— 早期评分比收入重要
2. 广告只在"导出/同步"等低频页放 Banner，**绝不在树视图和缅怀页放**
3. 定价对标 Quick FT（免费含广告），用"$19.9/年"降低决策门槛
4. **缅怀是最容易转化的付费点**（情感驱动 > 功能驱动），但**绝不能让免费用户觉得"不给钱就不能祭奠"** ——免费版必须保留完整的献花/点烛/留言闭环，Pro 只解锁"更多表达方式"
5. 后期可加：纸质家谱打印邮寄（Printful/Printify 按需，零库存）；纪念页二维码实体摆件

---

## 十、风险与对策

| 风险 | 等级 | 对策 |
|---|---|---|
| Supabase 免费项目 1 周不活跃暂停 | 🔴 高 | GitHub Actions 定时 ping；发布即升 Pro |
| Google Play 新账号 20人×14天 封闭测试 | 🔴 高 | 立刻注册账号；用亲友/Reddit r/Genealogy 招募测试者 |
| 家谱数据涉及在世人物隐私 | 🟡 中 | `is_living` 字段脱敏；默认私有；提供数据导出与彻底删除 |
| GDPR（欧盟用户）/ CCPA | 🟡 中 | 隐私政策、数据删除入口、Supabase 选欧洲区（eu-central-1）或按用户分布选区 |
| 树视图性能（5000+ 节点） | 🟡 中 | 分层渲染 + 折叠子树 + 只渲染可视区域（四叉树剔除） |
| GEDCOM 兼容性差（各家方言多） | 🟡 中 | 解析器容错优先，解析失败给"部分导入 + 错误报告" |
| 个人开发者精力有限 | 🟡 中 | 严格按 P0/P1/P2 排期，P2 一律推迟 |
| 名字/商标侵权 | 🟢 低 | 上架前查 USPTO + Google Play 包名 |
| 🔴 缅怀留言涉 UGC 违规内容 | 🔴 高 | 敏感词双重过滤 + 举报/屏蔽 + 默认仅家族可见 + 管理员可关闭留言；公开链接需显式开启 |
| ⚠️ 缅怀功能触犯宗教/文化禁忌 | 🟡 中 | 主题包按地区**推荐而非强制**；伊斯兰主题不提供烛/香/花圈；宗教符号可在设置中关闭；上线前请各文化背景用户试玩 |
| ⚠️ 机翻质量差影响评分 | 🟡 中 | 商店页 + 主流程 + 缅怀页人工校对（约 $400-700）；先上 12 种，按数据决定后续 |
| ⚠️ 多语言导致 UI 溢出/截断 | 🟡 中 | 全流程禁用写死宽度；伪语言测试；de/ja/ar 三真机必测 |
| ⚠️ RTL（阿拉伯语）改造返工 | 🟡 中 | **布局引擎架构阶段就把 `TextDirection` 作为参数传入**，Tier 2 上 `ar` 时只做验证不做重构 |
| ⚠️ CJK 字体撑大 AAB 体积 | 🟢 低 | 按 locale 动态加载字体子集，不全部内置 |
| 🟢 缅怀刷量 / 恶意留言攻击 | 🟢 低 | 客户端冷却 + 服务端限流 + 每日上限；异常 IP 告警 |
| ⚠️ **免费额度 1 朵/天过紧招差评** | 🟡 中 | ① **忌日当天豁免 +1**（必做）；② 额度做成服务端可配参数，看到负面情绪立即调到 2 朵/天；③ 耗尽提示必须给出"留言"等免费出口 |
| ⚠️ **地区自动推荐主题包判断错误** | 🟡 中 | 仅作预选值 + **首次必弹确认层**；`secular`/`western` 同屏可见；语言≠宗教，阿拉伯/土耳其/印尼地区必须能一键切到 `western` |
| ⚠️ 品牌名/包名被占用不可发布 | 🟡 中 | 见 11.6：**发布前必须在 Play Console 实测包名可用性**；包名一经发布永久不可更改，务必先建草稿验证 |

---

## 十一、附录

### 11.1 GEDCOM 关键标签映射

| GEDCOM | 我们的模型 |
|---|---|
| `INDI` | `persons` |
| `NAME` (given/surname) | `persons.given_name` / `surname` |
| `SEX` | `persons.gender` |
| `BIRT` / `DEAT` / `BURI` / `CHR` | `events`（type + date + place） |
| `OCCU` / `RESI` / `IMMI` | `events` |
| `FAM` | `families` |
| `HUSB` / `WIFE` | `families.partner1_id` / `partner2_id` |
| `CHIL` | `family_children` |
| `MARR` / `DIV` | `families.marriage_*` / `divorce_*` |
| `OBJE` / `FILE` | `media` |
| `SOUR` | `sources` + `citations` |
| `NOTE` | `persons.note` / `events.description` |

### 11.2 推荐依赖（pubspec 摘要）

```yaml
dependencies:
  # --- 基础 ---
  flutter_riverpod: ^2.6.1
  go_router: ^14.x
  drift: ^2.x
  sqlite3_flutter_libs: ^0.5.x
  supabase_flutter: ^2.x
  freezed_annotation: ^2.x
  json_annotation: ^4.x
  cached_network_image: ^3.x
  image: ^4.x            # 上传前压缩

  # --- 国际化 ---
  flutter_localizations:     # sdk: flutter
    sdk: flutter
  intl: ^0.20.x
  # 按需加载字体（避免 AAB 体积失控）
  google_fonts: ^6.x

  # --- 导出 ---
  pdf: ^3.x              # PDF 导出（含 CJK 字体嵌入）
  printing: ^5.x         # 预览/分享
  share_plus: ^10.x
  file_picker: ^8.x

  # --- 缅怀 ---
  flutter_local_notifications: ^17.x
  timezone: ^0.9.x       # 忌日提醒时区
  audioplayers: ^6.x     # 缅怀音效（默认关）
  # 动画：简单粒子用 CustomPaint 自绘；复杂角色动画可选 rive / lottie

  # --- 监控 ---
  sentry_flutter: ^8.x
  posthog_flutter: ^4.x
  package_info_plus: ^8.x

dev_dependencies:
  drift_dev, build_runner, freezed, json_serializable
  flutter_lints
```

并在 `pubspec.yaml` 顶层开启：
```yaml
flutter:
  generate: true   # 启用 flutter gen-l10n 自动生成 AppLocalizations
```

配套 `l10n.yaml`：
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
untranslated-messages-file: l10n_missing.txt   # 缺失翻译告警，接入 CI
```

### 11.3 竞品对照速查表

| 能力 | FamilySearch Tree | Quick Family Tree | **我们（V1）** |
|---|:---:|:---:|:---:|
| 免注册使用 | ❌ | ✅ | ✅ |
| 离线可用 | ⚠️ 部分 | ✅ | ✅ |
| 云同步多设备 | ⚠️ 有 bug | ❌ | ✅ |
| 多人协作 | ✅ | ❌（发文件） | ✅ |
| GEDCOM 导入 | ⚠️ 仅网页 | ❌ | ✅ |
| GEDCOM 导出 | ⚠️ 仅网页 | ❌ | ✅ |
| PDF 导出 | ❌ | ❌ | ✅ |
| 高清图导出 | ❌ | ⚠️ 仅截图 | ✅ |
| 多树管理 | ❌ | ✅ | ✅ |
| 焦点人物居中 | ❌ | ✅ | ✅ |
| 树手势体验 | ❌ 差评 | ✅ | ✅ 重点打磨 |
| **缅怀（献花/点烛/上香）** | ❌ 无 | ❌ 无 | ✅ **核心差异** |
| **缅怀留言墙** | ⚠️ 仅"故事"归档 | ❌ | ✅ |
| **忌日提醒** | ❌ | ❌ | ✅ |
| **纪念页分享（Web/扫码）** | ❌ | ❌ | ✅ 裂变点 |
| **多语言** | ⚠️ 少数几种 | ⚠️ 英日为主 | ✅ **12 种 + 自动匹配** |
| 历史档案匹配 | ✅ 海量 | ❌ | ❌（后期） |
| 家族地图 | ✅ | ❌ | P1 |
| 广告 | 无 | 有（无去广告） | 有（可去） |
| 评分 | 3.8 | 4.1 | 目标 **4.5+** |

### 11.4 缅怀节日日历（用于主题皮肤与推送运营）

| 节日 | 时间 | 主要地区 | 主题 |
|---|---|---|---|
| 清明节 | 4/4-5 | 中国/海外华人 | 素白、柳枝、青烟 |
| 盂兰盆节 Obon | 8/13-16 | 日本 | 灯笼、流水灯 |
| Pchum Ben（亡人节） | 9-10 月 | 柬埔寨 | 素白、供品 |
| 万圣节前夜 / 诸圣节 | 10/31 - 11/2 | 欧美天主教 | 暖橙烛光 |
| **Día de Muertos（亡灵节）** | 11/1-2 | 墨西哥/拉美 | 万寿菊、骷髅糖、彩色剪纸 |
| 排灯节 Diya | 10-11 月 | 印度 | 油灯、花环 |
| 逾越节 / 犹太纪念日 Yizkor | 按希伯来历 | 以色列 | 放石、长明烛 |
| 圣诞节 / 复活节 | 12/25、春分后 | 欧美 | 烛光、家庭团聚 |

> 建议：节日前 3 天推一条本地通知「XX 节将至，为想念的人点一盏灯」，
> 这是**全年最强的留存与回流钩子**，且完全本地计算、零服务端成本。

### 11.5 语言代码速查

| 语言 | code | 脚本/地区变体 | 备注 |
|---|---|---|---|
| English | `en` | en-US / en-GB | 兜底 |
| Español | `es` | es-ES / es-MX / es-419 | `es-419` 为拉美通用，建议单独支持 |
| Português | `pt` | pt-BR / pt-PT | **巴西与欧洲葡语差异大，优先 pt-BR** |
| Français | `fr` | fr-FR / fr-CA | |
| Deutsch | `de` | | 文本最长，重点测溢出 |
| Italiano | `it` | | |
| 日本語 | `ja` | | 需 CJK 字体 |
| 한국어 | `ko` | | 需 CJK 字体 |
| 简体中文 | `zh-Hans` | `zh` + script=Hans | |
| 繁體中文 | `zh-Hant` | `zh` + TW/HK/MO | |
| Русский | `ru` | | 复数规则 3-4 种 |
| Nederlands | `nl` | | |
| — Tier 2 — | | | |
| Polski / Türkçe | `pl` / `tr` | | |
| العربية | `ar` | | ⚠️ **RTL** |
| हिन्दी / Bahasa Indonesia / Tiếng Việt / ไทย | `hi` / `id` / `vi` / `th` | | 泰文需字体 |

### 11.6 品牌与命名定稿

#### ⛔ 品牌名：**Rootkeep** —— 已废弃（2026-10-09 复核确认被占用）

| 项目 | 状态 |
|---|---|
| **品牌名 Rootkeep** | ⛔ **废弃** |
| **包名 `app.rootkeep.tree`** | ⛔ **废弃**，不得使用 |

**废弃原因（2026-10-09 公开检索确认）：**

| 冲突方 | 证据 |
|---|---|
| `rootkeep.jerlah.com` | **已上线的同名 App** —— "Rootkeep is a small, private app for keeping up with the people you care about" |
| OTA RootKeeper | Android 老牌工具（root 隐藏），Google Play 内 `Root*` 词根噪音极大 |

> 用户反馈"有好几个产品叫 Rootkeep"属实。此前 11.6 章"未发现同名占用"的结论**已被推翻**。

---

#### 🪦 命名"墓地"：已排除的 30 个候选（供留档，避免重复踩坑）

2026-10-09 又排查了 24 个候选，**命中率 0%**。这暴露了一个结构性问题：

> **家谱 + 缅怀是命名最饱和的赛道之一，"有意义的英文复合词"基本已被挖空。**

| 候选 | 冲突证据 | 结论 |
|---|---|---|
| **第一轮（已排除）** | | |
| Kinora | Play 已有 `app.kinora`；USPTO #99722590 | ❌ |
| Famoria | App Store `Famoria™`（id6758868899） | ❌ |
| Everkin | USPTO 商标 #99860622 | ❌ |
| Stemma | mystemma.com 家谱平台 `Stemma™` | ❌ |
| Kinloom | `Kinloom™` 家庭聚会 App | ❌ |
| Ancestra / Ancestria | 与 Ancestry.com 近似，驳回风险高 | ❌ |
| Rootkeep | rootkeep.jerlah.com + OTA RootKeeper | ❌ |
| **第二轮 · `Kin*` / `Root*` 词根（饱和）** | | |
| Kinroot | Kinroot Wellness / Kinroot Creative / Kinroot 游戏公司 / 密苏里大学 Kinroot App | ❌ |
| Kinlume | 音近撞车：Kinolime、Kinlune、Kinglumi、KinLumens | ❌ |
| Rootloom | `Root*` 饱和：RootsLore、Rootrees、RootsRefined、OTA RootKeeper | ❌ |
| **第三轮 · 有意义的英文复合词（饱和）** | | |
| Forelore | forelore.ai（气候审计服务） | ❌ |
| Heartwood | `Heartwood Vault` —— "Build Your Family Legacy"（**直接竞品**）+ Heartwood Online MMO | ❌ |
| Lorekeep | LoreKeep 阅读追踪器 / LoreKeeper (D&D) / PyPI lorekeep | ❌ |
| Everloom | everloom.io / everloombrand.com / The Everloom 游戏 | ❌ |
| Heirloom | **至少 7 个**：heirloom.quest「Build your family tree together」**直接竞品**、heirloomfamily.app、heirloom.fm、heirloom-app.com 等 | ❌ |
| Hearthside | Hearthside: Cozy Cooking Pet（App Store）/ Hearthside Bank / 游戏 | ❌ |
| Avelore | avelore.com 珠宝品牌 + TapTap 同名游戏 | ❌ |
| **第四轮 · `X-keep` 族（饱和）** | | |
| Grovekeep | Steam 游戏《Grove Keeper》 | ❌ |
| Clankeep | clankeep.com 已在运营（家庭用药记录 App） | ❌ |
| Namekeep | namekeep.com 1998 年已注册 + 与 Namecheap 近似 | ❌ |
| Storykeep | trystorykeep.com / storykeep.com / storykeep.cc / ourstorykeep.com（**4 个家族故事 App**） | ❌ |
| **第五轮 · 多语词根 / 古语 / 植物拉丁名（饱和）** | | |
| Cedrus | cedrus.com（1991 年至今的刺激呈现软件商）、CedrusMed、CUBUS CEDRUS | ❌ |
| Pietas | 搜索结果被 **Pilates** 全面污染，ASO 灾难 | ❌ |
| Votive | 宗教通用词，殡葬服务占位 | ❌ |
| Nemora | Nemora AI（AI 女友）+ nemora.ai + Nemora Games —— 且有 NSFW 联想 | ❌ |
| Klados | klados.bio（生物分类平台，**撞 phylogenetic tree**）、Klados 酒庄、Klados 物流 | ❌ |
| Memoriam | memoriam.cn 社群纪念 App + App Memoriam (Novacorp) | ❌ |
| Ricordo | ricordo.app + App Store Ricordo（健康）+ ricordo.blog | ❌ |
| Amparo | amparo.app + **Amparo 丧亲服务平台（直接相关）** + Amparo Technologies | ❌ |
| Vamsha / Vamsa | vamsh.app「Build your family tree together」**直接竞品**、vamsa.app「Your Living Lineage」、Vamshavriksha、Vamshadhara | ❌ |
| Marula | Marula Games OU（App Store 开发商，多款游戏）、Marula Proteen | ❌ |
| Sapline | saplinepharma.com + SAPLINE 灯具 + 沙特 Aramco SAPLINE 管道 + BSC 代币 + 与 Sapling.ai 近似 | ❌ |
| Verdeline | FERRO 卫浴产品线型号 VERDELINE | ❌ |
| Everline | everline.jollyany.co + 被 Verizon Family 污染 | ❌ |
| Ancestro | 搜索结果被 Ancestry 完全淹没，商标近似高风险 | ❌ |
| **第六轮 · 描述性短语（占用 + 无法注册，双重否决）** | | |
| **Eternal Family Tree** | ① `EternalInk.io` 直接以"**Build the Eternal Family Tree**"为核心标语（AI 纪念家谱，定位重叠）② 永生樹 **Eternal Tree**（eternal-tree.com）协作家谱竞品 ③ **Eterna**（eterna.family）④ USPTO `ETERNAL FAMILY LEGACY` #99303801（申请人即 Family Legacy App LLC）⑤ USPTO `ETERNAL` #86536756 覆盖 *memorial profiles for deceased* ⑥ USPTO `ETERNAL LEGACY` #99866956 | ⛔ **双重否决**：已占用 **且** 纯描述性短语，USPTO 必判 merely descriptive |

| **第七轮 · 拉丁词根方向（全灭）** | | |
| **Perenna Tree** | 词组本身干净，但 `Perenna` 单字严重占用：**Perenna Bank**（英国持牌抵押贷款银行，perenna.com，获 Smart Money People 奖）、perenna.ro 矿泉水 Perenna Premier、perennahealth.com、歌手 Perenna King、且是英文女子名。另 `Tree` 违反原则第 5 条 | ⛔ 词组干净但词根被占 + 含通用词 `Tree` |
| Perennia | perennia.ca（Nova Scotia 食品发展局）、**Perennia Fiduciary**（亚洲家族信托"为传世而建"）、perennia.tech（AI）、perennia.dev | ❌ |
| Aevum | aevum.com（航空航天）、aevum.world、aevum.build、aevum.technology、aevumtech.net、Snap Store aevumwriter、GitHub 多个 | ❌ |

| **第八轮 · 藤蔓 / 攀援语义域（用户提议方向，同样全灭）** | | |
| **Vine** | Twitter/X 旗下短视频 App（2013–2016，巅峰 2 亿用户），商标归 X Corp；马斯克 2022 年公开表示要复活。另 4 字母 → 域名/社交账号无法获取，ASO 噪音极大 | ⛔ |
| VineTree | 含通用词 `Tree`（违反原则第 5 条）；且"藤蔓"与"树"是两种不同生长形态，隐喻互相打架；camelCase 非 App 命名常规 | ⛔ |
| familyVine / Family Vine | 含通用词 `Family` → 描述性；camelCase 非命名常规 | ⛔ |
| Vinea | vinea.co.nz 葡萄园管理软件 + Microsoft AppSource Vinea + vineaspirit.ca 葡萄利口酒 | ❌ |
| Tendril | **7 个**：tendril-app.com、tendrilapp.ai、usetendril.com（思维导图）、tendril.uk、tendrilcloud.app、gettendril.app、App Store Tendril Mindmap（其文案即"Grow your ideas like vines"） | ❌ |
| Liana | Liana Technologies Oy（芬兰营销自动化，App Store LianaMonitor）+ 常见人名（亚/俄/葡/罗） | ❌ |
| Hedera（常春藤属） | Hedera Hashgraph 区块链，极其有名 | ❌ |
| Ivy（常春藤） | 常春藤联盟 + 大量 App + 常见人名 | ❌ |
| Ampelos（希腊语"藤"） | 语义完美（狄俄尼索斯所爱萨堤尔化为葡萄藤），但 ampelos.gr 希腊神职服装公司 + 扎金索斯景点 + P5X 游戏角色；且神话含同性爱叙事，保守市场有联想风险 | ⚠️ 高风险 |
| Pergola（藤架） | 无同名 App，但 SEO 被"庭院棚架设计软件"完全占满（Pergola Planner、PergoFlow） | ⚠️ 噪音大 |
| Trellis（藤架） | **7+ 个**：trellissuite.com、**Vertiv Trellis™（注册商标）**、**trellisag.com（葡萄园管理软件，正撞 vine 域）**、Trellis Company、Trellis AI(YC)、Trellis Energy | ❌ |

> 💡 **但"藤蔓"这个意象本身是对的，甚至优于"树"**：
> 树 = 层级、单向（根→干→枝），是 19 世纪家谱的过时隐喻；
> 藤蔓 = **连接、缠绕、蔓延、无单一中心** —— 更贴近真实家族网络（姻亲、多重关系、横向连接），且藤蔓常青正好对应"缅怀纪念"。
> **方向值得坚持，只需换一个未被占用的词根。**

| Lares（罗马祖先守护神） | lares.com（网络安全红队）、Ksenia lares 4.0（家庭自动化 App，App Store）、lares.talk、laresglobal.com、laresconsulting.com | ❌ |
| Ostinato（音乐反复动机） | ostinato.org（网络流量生成器）+ App Store Ostinato（音乐 App）+ GetApp/Capterra 收录 | ❌ |
| Antiphon（应答圣歌） | antiphon168.com（广州软件公司）｜另有基督教音乐联想 | ⚠️ |

### 🎉 第九轮 · 跨语义域（任意性商标）—— 首个突破

**方法论转变**：不再在「家谱/缅怀」语义域里挖（已挖空），改用 **任意性商标（arbitrary mark）**
—— 借用一个**与家谱完全无关领域**的词。这是商标法里**保护力最强**的一类（Apple 之于电脑、Amazon 之于电商）。

本次从**古罗马家庭宗教**这一完全不搭界、却语义精准的域切入：

| 候选 | 语义 | 检索结果 |
|---|---|---|
| ✅ **Lararium** | 罗马人家中供奉 **Lares（祖先守护神）** 的神龛 | **零占用**（两轮检索：仅考古/古典学内容，无任何 App/软件/商业品牌） |
| ✅ **Caristia** | 罗马 **2 月 22 日家族团聚祭祖节**（cara cognatio = "亲爱的亲属"），是 Parentalia 祭祖九日的收尾庆典 | **零占用**（仅 Oxford Classical Dictionary 等古典学文献）|

> 📊 **截至 2026-10-09：共排查 49 个候选。**
> 前 47 个全部撞车（0% 命中）—— 证明"家谱语义域"已被系统性挖空，逐个猜名是无效循环。
> 第 48–49 个（Lararium / Caristia）**首次零占用** —— 证明**跨语义域 + 任意性商标**是唯一有效路径。

> ⚠️ **重要教训**：`Family Tree` 是家谱软件的**通用描述词**，`Eternal` 在该类别同属常见描述词。
> 两者组合 = 纯描述性短语 → **不仅已被占用，即使无人占用也注册不了商标，且注册成功也无法阻止他人使用。**
> 因此：**品牌名本体不得包含 `Family Tree`**；`Family Tree` 只作为 Play 标题里的关键词后缀（`<Brand>: Family Tree`）。

**同时发现的同赛道竞品（对产品定位有参考价值）：**

| 竞品 | 定位 |
|---|---|
| `heirloom.quest` | "Build your family tree together" —— 协作家谱 + 审核变更 |
| `vamsh.app` | 精确亲属称谓 + 任意两人关系路径（**功能点值得抄**） |
| `vamsa.app` | 「Your Living Lineage」家谱 + 照片故事 |
| `MemoriaTree` | 家谱 + 纪念页互连 |
| `heartwoodvault.com` | 家族故事定时投递 |
| `Rootrees` | 华人市场家谱（农历生日、时辰、多配偶） |
| `EternalInk.io` | 家谱 + AI 纪念（"add a soul"、"talk to your loved ones forever"） |
| `永生樹 Eternal Tree` | 协作家谱（50 编辑者）+ 口述历史录音 + 年度家族纪念册 |
| `Kintree` / `Ancestorly` | 家谱 + 故事 + 传承 |
| `iRitual - Family Tree`（App Store） | **每个名字旁显示真人面貌、故居、生活习惯**——人物卡设计值得参考 |
| `Tree of Memories` / `Memory Banx` | 纪念页 + 家族记忆 |

---

#### ✅ 定稿策略：**包名与品牌名解耦**（这是本轮最重要的结论）

既然品牌名难产且**包名一经发布永久不可改**，而品牌名随时可改 —— 那就**不要把两者绑死**。

| 项 | 规则 | 原因 |
|---|---|---|
| **Android 包名 / iOS Bundle ID** | 用**你已拥有的域名反写**或**开发者主体名**，**不含品牌词** | ① 域名是你独有的 → 包名必然全球唯一，不可能被占用<br>② 不含品牌词 → 将来改名**不需要动包名**<br>③ 用户永远看不到包名 |
| **商店显示名（Play 标题）** | 品牌名 + 关键词，如 `<Brand>: Family Tree` | **改标题不需要发新版本**，Play Console 改完 24h 内生效 |
| **域名根** | 与包名同一域名 | 保持一致，便于维护 |

#### ✅ 已定稿的包名（2026-10-09）

```
Android applicationId : com.ay1px.tree    ← 已锁死，永不更改
iOS Bundle ID         : com.ay1px.tree    ← 与 Android 保持一致
Play 显示名           : Lararium: Family Tree  ← 21 字符，随时能改（不需发版）
```

**合法性校验 ✅（Android `applicationId` 规则逐条核对）**

| 规则 | `com.ay1px.tree` | 结果 |
|---|---|---|
| 至少 2 个分段（点分隔） | `com` / `ay1px` / `tree` = 3 段 | ✅ |
| 每段必须以**字母**开头 | `c` / `a` / `t` | ✅ |
| 只允许字母、数字、下划线 | 仅含 `a y 1 p x` 等字母数字 | ✅ |
| 不得使用 Java/Kotlin 保留字 | `com`、`ay1px`、`tree` 均非关键字 | ✅ |
| 建议全小写 | 全小写 | ✅ |

> ✅ `ay1px` 是随机 token，与品牌无关 → **将来改名不必动包名**，且全球撞名概率接近 0。
> ⚠️ 仍需按惯例在 Play Console 建空壳草稿实测一次（唯一权威验证）。

> 🚨 **因此：品牌名难产不再阻塞开发。**
> 立刻用域名反写建「空壳草稿应用」锁死包名，Flutter 可以先开工；品牌名并行慢慢筛。

#### 新品牌名的生成原则（基于 30 个失败案例反推）

**必须避开这些词根**（本轮证明已饱和）：
`Root*` `Kin*` `Fam*` `Ancestr*` `Heritage` `Tree*` `Lore*` `Lum*` `Mem*` `Ever*` `Nem*` `Klado*` `Vot*` `Cedr*` `Heart*` `Fore*` `Stem*` `Grove*` `Story*` `Name*` `Clan*` `Lineage` `Saga` `Willow` `Ember` `Hearth` `Radix` `Codex` `Vellum` `Tessera`

**应该采用**：
1. **纯自造词**（无词典含义）→ 商标显著性最强、碰撞概率最低
2. 2–3 音节、6–9 字母，在 ES/PT/FR/DE/IT/JA/KO/ZH 均可自然拼读
3. **语义交给标题承担**，品牌名本身不必"望文生义"——ASO 由 `Family Tree` 关键词承担
4. 避开其他语言的负面联想（务必逐语种过一遍）
5. 🔴 **品牌名本体不得包含 `Family Tree` / `Tree` / `Ancestry` 等通用描述词** —— 否则 USPTO 判 merely descriptive，注册不了也保护不了（`Eternal Family Tree` 的教训）

#### 🔎 批量筛选流程（逐个猜名已被证明无效，改用批量）

```
Step 1  批量生成 40+ 候选（见下方词表）
Step 2  批量初筛 —— 域名可用性（最快，1 分钟筛掉 70%）
        ├─ instantsearch.inc / namelix.com / lean domain search
        └─ 判据：.com 与 .app 同时被占 → 直接淘汰
Step 3  幸存者（约 10 个）逐个走：
        ├─ USPTO TESS（第 9 类 + 第 42 类）
        ├─ Google 搜 "<名> app" 与 "<名> genealogy"（双查，缺一不可）
        ├─ Play Console / App Store Connect
        └─ namechk.com 查社交账号
Step 4  剩下 1–2 个 → 定稿
```

#### 🏆 首选推荐：**Lararium**（2026-10-09 · 49 个候选中首个零占用）

| 项 | 说明 |
|---|---|
| **读音** | la-RA-ri-um（/ləˈrɛəriəm/），8 字母 |
| **语义** | 古罗马家庭中供奉 **Lares（祖先守护神）** 的神龛 —— 每家必设，每日于中庭向祖先献祭、追念 |
| **为什么是它** | ① **一次覆盖两大卖点**：家谱（祖先 lineage）+ 缅怀（神龛/祭坛 memorial），正是 lararium 的本义<br>② **任意性商标**（古罗马宗教术语 → 家谱软件）→ 商标法保护力最强的一类<br>③ **两轮检索零占用**，无同名 App/软件/商业品牌<br>④ **非描述性** → 不触发 merely descriptive，USPTO 第 9 类可注册<br>⑤ 罗曼语族天然同源：西语/意语即 `larario`，ES/IT/PT/FR 市场零学习成本 |
| **Play 标题** | `Lararium: Family Tree`（21 字符，上限 30）✅ |
| **Logo 方向** | 小型壁龛/神龛轮廓 + 龛内**烛光** —— 与既定的「根系 + 烛光」方案一脉相承，且更易做 48px 单色图标 |
| **Slogan 建议** | *The shrine your family keeps.* |

**需注意的点（不致命）**

| 风险 | 评估 |
|---|---|
| 4 音节偏长 | Play 标题靠 `Family Tree` 承担 ASO，品牌名长度影响可控 |
| 罗马多神教背景 | 属中性历史文化符号；建议上市前在目标市场做一次联想测试 |
| 需权威核验 | 仍须走 USPTO TESS + Play Console + 域名/社交账号流程 |

**备选**

| 候选 | 说明 | 风险 |
|---|---|---|
| `Caristia` | 罗马家族团聚祭祖节，更温暖（词根 *carus* = 亲爱的） | ⚠️ 与 **Caritas**（国际明爱，全球天主教慈善组织）仅差一字，商标近似风险 |
| `Vinora` | 自造词，`vin-`（藤蔓）+ `-ora` | 尚未核验 |

> ⚠️ **Lararium 尚未走 USPTO / Play Console 权威核验** —— 但它是 49 个候选里唯一零占用者，核验通过概率显著高于此前任何一个。

#### 🎯 此前推荐（已降级为备选）：**Vinora**

| 项 | 说明 |
|---|---|
| 构造 | `vin-`（藤蔓，保留意象）+ `-ora`（自造词尾） |
| 为什么是它 | ① **保留藤蔓意象**但避开 Twitter 的 `Vine` 品牌本体 ② **纯自造** → 可注册商标（不像 `VineTree`/`Family Vine` 那样 merely descriptive）③ 3 音节、温暖、12 语种可读 ④ 不与 `Tree`/`Family` 等通用词组合 |
| Play 标题 | `Vinora: Family Tree`（20 字符，上限 30）✅ |
| 备选 | `Vinelle` / `Vinera` / `Vinarya` / `Wisteria`（紫藤，东亚家纹意象） |

> ⚠️ **Vinora 尚未核验** —— 需走 Step 2/3 流程确认。

#### 📋 批量候选词表（40 个，供 Step 2 批量粘贴查询）

> 全部为**纯自造词**，已避开所有已证实饱和的词根
> （`Root*` `Kin*` `Fam*` `Ancestr*` `Lore*` `Lum*` `Mem*` `Ever*` `Nem*` `Tree*` `Grove*` `Story*` `Name*` `Clan*` `Heart*` `Fore*` `Stem*` `Perenn*` `Aev*` `Etern*`）
> 6–7 字母 / 2–3 音节 / 仅用 a e i o u + l m n r v t d s b p k f（避开 x q z j，保证 12 语种可读）

```
Liora    Velora   Orena    Ilvana   Sovara   Noravi   Toravi   Rovena
Lavena   Varena   Sorena   Varina   Kovena   Molena   Navira   Yovena
Idara    Pelora   Venora   Virela   Melori   Kavella  Elvari   Novari
Torina   Orina    Tuvara   Rovani   Dovani   Kireva   Tivara   Laruna
Kalira   Meravi   Seluri   Tavira   Dovela   Keravi   Milora   Olvari
```

> ⚠️ **以上 40 个均未做任何检索**，不保证可用 —— 它们是 Step 2 批量初筛的**输入**，不是结论。

#### ⬜ 待验证候选（**尚未核验，必须先走核验流程再定稿**）

> 以下为待筛起点，**未做任何检索，不保证可用**。按"自造程度"排序：

| 候选 | 构造 | 备注 |
|---|---|---|
| `Liora` | 希伯来语「我的光」 | 贴合烛光纪念；需查是否已被珠宝/护肤品牌占用 |
| `Veloria` / `Orelia` | 纯自造 | 无词典含义，显著性最强 |
| `Virelia` | 纯自造 | 同上 |
| `Ilvaris` / `Kelvane` | 纯自造 | 同上 |
| `Sapline` | sap + line | ❌ 已排除（见墓地表），仅作构造示例 |

#### 🔴 品牌名核验流程（唯一可信路径）

> ⚠️ **公开网页检索无法完成清名**（本轮 30 个候选 0% 命中率已证明）。
> 必须用下面 4 个权威源，缺一不可。

```
1. Google Play Console → 创建应用 → 填包名，看是否提示"已被占用"
   └─ 用域名反写的包名，此步基本必然通过；同时完成"空壳草稿占位"
2. USPTO TESS (tmsearch.uspto.gov) → 检索品牌名，第 9 类（计算机软件）
   └─ 同时检索第 42 类（SaaS）
3. App Store Connect → 检查 Bundle ID
4. 域名注册商 + namechk.com → 查域名与 X/TikTok/Instagram 同名账号
5. Google 搜索 "<品牌名> app" + "<品牌名> genealogy" 双查
   └─ 本轮教训：必须加行业词搜，否则查不出同赛道冲突
```

> 🚨 **最容易被忽略的坑**：Google Play 的**包名一经发布永久不可更改**（连删除应用后该包名也会被永久保留）。
> 所以**第一步就在 Play Console 建草稿验证包名**，再开始写代码。

#### Google Play 商店文案（英文，其余 11 语言照此机翻 + 校对）

**标题（≤30）** — 已定稿
```
Lararium: Family Tree        ← 21 字符
```
> 品牌名 8 字母 + `Family Tree` 刚好落在 30 字符内。改标题**不需要发新版本**。

**简短描述（≤80）**
```
Build your family tree offline. Export GEDCOM & PDF. Light a candle in memory.
```

**完整描述（≤4000）关键词埋点**
```
family tree · genealogy · ancestors · pedigree · family history · lineage ·
roots · memorial · in memory · remembrance · condolence · GEDCOM ·
ancestor chart · deceased relatives · virtual flowers · candle
```

**多语言 Slogan（机翻，上线前需母语者校对）**

| 语言 | Slogan |
|---|---|
| en | Keep your roots. Remember them forever. |
| es | Conserva tus raíces. Recuérdalos para siempre. |
| pt | Guarde suas raízes. Lembre-se deles para sempre. |
| fr | Gardez vos racines. Souvenez-vous d'eux pour toujours. |
| de | Bewahre deine Wurzeln. Erinnere dich für immer. |
| it | Custodisci le tue radici. Ricordali per sempre. |
| ja | ルーツをつなぎ、想いを永く。 |
| ko | 뿌리를 지키고, 오래도록 기억하세요. |
| zh-Hans | 守住家族的根，留住永恒的思念。 |
| zh-Hant | 守住家族的根，留住永恆的思念。 |
| ru | Сохрани свои корни. Помни их вечно. |
| nl | Bewaar je wortels. Herdenk ze voor altijd. |

---

## 十二、下一步

**已定稿（本轮确认）**

| 决策项 | 结论 | 位置 |
|---|---|---|
| App 名 | 🏆 **Lararium** —— *The shrine your family keeps.*（待 USPTO 核验） | 11.6 |
| 包名 / Bundle ID | ✅ **`com.ay1px.tree`**，与品牌名解耦 | 11.6 |
| 免费版献花上限 | **1 朵/天**（其余动作各 1 次/天，留言 3 条/天，忌日 +1） | 5.4.4 |
| 缅怀默认主题包 | **按地区自动推荐 + 首次弹层可自选一次**（之后随时可改） | 5.4.3 |
| 首版语言 | 12 种，按设备语言/地区自动匹配 | 5.3 |

**待办**

1. 🔴 **立刻做**：在 Play Console 建空壳草稿应用，实测并占位 `com.ay1px.tree`（**包名永久不可改**）
2. **立刻做**：招募封闭测试者（20 人 × 14 天），可从 Reddit `r/Genealogy`、亲友、华人/拉美社群入手
3. **本周做**：核验 **Lararium** —— USPTO TESS（第 9/42 类）+ Play 包名 + `lararium.com` 与社交账号；若被驳回则启用备选 `Caristia` / `Vinora`
4. **本周做**：创建 Supabase 项目，搭 Flutter 脚手架（flavors: dev/prod）
5. **本周做**：手绘/AI 出 15-20 张关键页面草图（树视图、人物编辑、导出、同步状态、**缅怀页**、**首次主题选择弹层**、**纪念墙**）
6. **本周做**：定稿 12 种语言清单 + 建 `app_en.arb` 骨架与术语表

**仍需你拍板的**

- [ ] Logo 方向确认：**神龛/壁龛轮廓 + 龛内烛光**（原型已采用此方案，替代原「根系 + 烛光」）—— 是否认可？
- [ ] 12 种语言里 `nl` 是否要换成 `pl`（波兰，家谱需求高）或 `hi`（印度，人口大）？
- [ ] 纪念页默认是否公开？（建议**默认仅家族可见**，公开需管理员手动开）
- [ ] 是否需要我直接开始搭 Flutter 项目骨架 + 数据库模型 + l10n 骨架？

---

*数据来源：Google Play 商店页面（org.familysearch.mobile / com.digitalgene.familytree，查询于 2026-10-09）、Digital Gene 官网 FAQ、Supabase 官方定价页。*
