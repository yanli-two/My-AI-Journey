# QQ 机器人 · AstrBot + SnowLuma

QQ 号：**3695820197**（昵称：空晞）
部署位置：`D:\AI\QQBot`
部署方式：全部为用户级/绿色安装，**不需要管理员权限**，不依赖 Docker。

---

## 一、架构

```
好友 / 手机 QQ
      │  收发消息
      ▼
┌─────────────────────────────┐
│ SnowLuma 2.2.1（Hook QQNT） │  挂载本机 QQ 9.9.31
│  WebUI        127.0.0.1:5099│
│  OneBot HTTP  127.0.0.1:3000│
│  OneBot WS    127.0.0.1:3001│
└──────────┬──────────────────┘
           │ 反向 WebSocket  ws://127.0.0.1:6199/ws（token 鉴权）
           ▼
┌─────────────────────────────┐
│ AstrBot 4.29.3（Python 3.12）│
│  WebUI       127.0.0.1:6185 │
│  反向 WS       :6199        │
│  模型  deepseek-flash       │
└─────────────────────────────┘
```

五个端口全部只绑 `127.0.0.1`，局域网/公网都访问不到。
**服务以隐藏窗口运行**（任务栏不会出现黑框），另有一个看门狗每 45 秒检查一次，进程死掉会自动拉起。

## 二、脚本一览

| 脚本 | 作用 |
|---|---|
| `start-all.bat` | **手动启动用**：静默拉起两端 + 打开 AstrBot 面板 |
| `stop-all.bat` | 停止：先让看门狗退出，再按端口杀进程 |
| `health-check.bat` | **体检**：端口 / QQ 在线 / 适配器连接状态 |
| `start-hidden.ps1` | 静默启动实现（清停止标志 → 起 SnowLuma → 起 AstrBot → 起看门狗） |
| `stop-all.ps1` | 停止实现（写停止标志 → 杀看门狗 → 杀两个服务） |
| `watchdog.ps1` | 看门狗：端口没监听就重启对应服务；发现停止标志则自行退出 |
| `run-snowluma.bat` / `run-astrbot.bat` | 带日志重定向的单体启动器 |

## 三、开机自启

注册表项（当前用户，无需管理员）：

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Run
  QQBot = powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "D:\AI\QQBot\start-hidden.ps1"
```

> 注意：启动文件夹里的快捷方式会被本机安全软件在 10 秒内静默删除（已实测），所以改用 Run 键。
> 想关掉自启：删除 `HKCU\...\Run` 下的 `QQBot` 这一项即可。

## 四、目录与配置

| 路径 | 作用 |
|---|---|
| `snowluma\` | SnowLuma 运行目录（自带 node.exe 24.22.1） |
| `snowluma\config\onebot_3695820197.json` | 该号的 OneBot 节点配置（含反向 WS 客户端） |
| `astrbot\` | AstrBot 源码 |
| `astrbot\data\cmd_config.json` | 主配置（平台 / 模型 / 管理员 / 唤醒前缀） |
| `venv\`、`python\` | Python 虚拟环境与用户级 Python 3.12.8 |
| `_logs\snowluma.log`、`_logs\astrbot.log` | 两端日志（每次启动覆盖） |
| `_logs\watchdog.stop` | 存在即表示"人工停止"，看门狗会退出 |

| 面板 | 地址 | 账号 |
|---|---|---|
| AstrBot | http://127.0.0.1:6185 | `astrbot` + 首启随机密码（见日志 `Initial password:`，**请尽快改**） |
| SnowLuma | http://127.0.0.1:5099 | `admin` + 你改过的密码 |

SnowLuma 密码忘了：停服务 → 删 `snowluma\config\webui.json` → 启动，日志里会给新密码。

## 五、常用配置

**换模型**：`cmd_config.json` → `provider` 段的 `"model"`
- `deepseek-flash`：当前使用，快、便宜、支持看图
- `deepseek-v4-pro`：更强，慢一些贵一些

**改人设**：AstrBot 面板 →「人格」→ 默认人格的系统提示词。

**群聊唤醒**：`wake_prefix` 当前 `["/"]`——私聊随便说，群里要 `/` 开头或 @机器人；改成 `[]` 则群里任意消息都回（不建议）。

**管理员**：`admins_id = ["3695820197"]`。

## 六、故障排查

| 现象 | 处理 |
|---|---|
| 机器人不说话 | 双击 `health-check.bat`；四个端口都 OK 且 `QQ online: YES` 说明链路正常，多半是模型侧问题，看 `_logs\astrbot.log` |
| 端口没起来 | 手动双击 `start-all.bat`；看 `_logs` 末尾报错 |
| `get_status` 401 / QQ 不在线 | SnowLuma 没 Hook 上 QQ：`stop-all.bat` → 等 15 秒 → `start-all.bat` |
| 日志出现 `^C` | 进程被手动/外部终止（例如关掉了控制台窗口）。现已改为隐藏窗口 + 看门狗，正常不会再出现 |
| 面板打不开 | 对应端口没监听，先看健康检查 |

## 七、安全

- API Key 明文存于 `astrbot\data\cmd_config.json`，勿外传
- 面板仅监听 `127.0.0.1`；远程访问请走 SSH 隧道，不要改 `0.0.0.0`
- 机器人以你本人 QQ 身份发言，注意隐私与群规

## 八、人格与表情包（2026-11-11 新增）

### 1. 表情包插件

位置：`astrbot\data\plugins\astrbot_plugin_qingxu\`

| 文件 | 作用 |
|---|---|
| `main.py` | 插件逻辑（关键词匹配、冷却、发图） |
| `keywords.json` | 关键词 → 图片 + 台词，改这个**不用重启** |
| `assets\*.png` | 图片文件，用自己的表情包同名替换即可 |

当前规则：`hug`(抱抱) / `pat`(摸摸头) / `kiss`(亲亲) / `wuyu`(无语，仅 8 字以内短句)。

设计约束（都是为了降低风控）：
- 一次触发只发**一条**消息（图片+文字合成一条，不是两条）
- 触发后 `should_call_llm(True)` 阻止大模型再回一条
- 每个用户 **30 秒冷却**
- `private_only: true`，群聊不触发
- `max_len` 限制，避免长句里出现"无语"就机械发表情

加一个新表情（不用重启 AstrBot）：
1. 把图片放进 `assets\`，比如 `angry.png`
2. 在 `keywords.json` 加一段：
```json
"angry": { "keywords": ["哼", "生气了"], "image": "angry.png", "text": ["……哄我。"] }
```
3. 保存即可，下一句话生效（插件按文件修改时间热加载）

### 2. 人格（System Prompt）

人格**不在** `cmd_config.json` 里，而在 SQLite：`astrbot\data\data_v4.db` 的 `personas` 表，
`persona_id = default` 那一行。`agent_runner.config.persona.persona_id` 指向它。

- 当前人格：空晞（911 字符）+ 8 条 few-shot 开场对话
- 修改方式一（推荐）：AstrBot 面板 →「人格」→ 编辑 default → 保存（改完重启 AstrBot 生效）
- 修改方式二：停 AstrBot → 改数据库 → 启动；每次改动前备份 `data_v4.db`
- 备份文件：`astrbot\data\data_v4.db.bak-YYYYMMDD-HHMMSS`

注意：AstrBot 的 `safety_mode` 会在人格前插入一段英文安全提示（"prefer healthy, constructive, positive responses"），
会把语气磨平。人格末尾已加一句"语气不受礼貌/正面要求影响"，用来抵消这个副作用；
如果哪天觉得她说话又开始像客服，先检查这句还在不在。

### 3. QQ 表情包转图片（`astrbot_plugin_mface`）

位置：`astrbot\data\plugins\astrbot_plugin_mface\`

**为什么原来收不到**（两个独立的原因，必须都修）：
1. AstrBot 的 aiocqhttp 适配器对 `mface` 段直接 `continue` 丢弃（硬编码，无配置项）；
2. 适配器只把 `Plain` 文本拼进 `message_str`，`face` 段只进组件列表。于是「纯表情消息」的
   `message_str` 是空串，Agent 阶段判定 "empty message and no provider_request" 直接返回——
   模型根本没有获得这次对话轮次（日志里连 `Prepare to send` 都不会出现）。

**插件做了三件事**：
1. `ensure_face_text`：纯表情消息补一句「（发来一个表情：偷感）」，让流水线继续；
2. `fetch_sys_faces`：向 SnowLuma 拉系统表情目录（`q_sid → q_des / url`），缓存 1 小时；
3. `inject_face_images`：目录里的 `url` 是**动图 zip 包**，下载后解压取中间一帧转 PNG，
   缓存到 `cache\<sid>.png`，再塞进 `req.image_urls` 交给模型。

**配置**（`config.json`，改完自动生效）：

| 键 | 默认 | 说明 |
|---|---|---|
| `inject_image` | true | 是否把表情图交给模型 |
| `max_images` | 2 | 单条消息最多注入几张 |
| `replace_text` | true | 把 `[表情:427]` 换成 `[表情:偷感]` |
| `fill_text` | true | 纯表情消息是否补文本（关掉就等于退回原样） |
| `catalog_ttl_seconds` | 3600 | 表情目录缓存时间 |
| `download_timeout` | 8 | 下载动图包超时（秒） |

**验证方法**：让对方发一个系统小黄脸，`_logs\astrbot.log` 里应出现
`系统表情目录已加载：398 条`、`表情图已缓存：427.png`、`已注入 1 张表情图片`。

**说明**：收藏/商城表情若已经被 SnowLuma 转成 `image` 段（带 url），走的是 AstrBot 原生图片链路，
本来就能看见；这个插件主要补的是 `face`（小黄脸/大表情）这一类只有 id、没有图的消息。

## 九、上下文与长期记忆

### 1. 上下文（`astrbot\data\cmd_config.json`）

```json
"agent_runner": { "config": { "compression": {
    "max_turns": -1,          // -1 = 不限轮数（不是"1 轮"）
    "keep_recent_ratio": 0.55, // 压缩时保留 55% 原文
    "overflow_strategy": "llm_compress"
} } }
```

- `max_turns = -1` **本身就是无上限**，改成 20/30 反而会砍掉历史，所以保持 -1。
- 真正的"失忆"来自 `llm_compress`：触发压缩时，旧消息被替换成一段摘要，细节永久丢失。
  把 `keep_recent_ratio` 从默认 0.15 提到 0.55，压缩后保留的原文多得多。
- 模型窗口由 provider 的 `max_context_tokens` 决定（deepseek-flash 为 1M，实际很少触发压缩）。
- 会话原文存在 `astrbot\data\data_v4.db` 的 `conversations` 表，重启不丢。

**已知代价**：一次请求带上 300 条历史（约 4.6 万 tokens）时，单次回复要 60–90 秒。
想更快就把 `max_turns` 设成 60~80（记忆变浅、速度变快），记忆卡不受影响。

### 2. 长期记忆（`astrbot\data\plugins\astrbot_plugin_memory_lite\`）

AstrBot 4.29.3 **没有**自带 Memory 插件（`builtin_stars` 只有 astrbot 和 builtin_commands，
`provider_ltm_settings` 只是群聊历史注入）。这个插件是本地实现，不依赖 embedding：

| 文件 | 作用 |
|---|---|
| `memory.jsonl` | 每轮对话原文，追加写 |
| `facts.json` | 抽取出的长期事实，原子写，每次请求注入系统提示 |

- 每 8 轮自动整理一次（用当前对话模型，不额外配服务）
- 命令：`/记忆` 查看全部，`/记忆整理` 立刻整理
- 配置 `config.json`：`inject`、`update_every`、`max_facts`、`recent_for_update`、`debug_context`

**验证**：每次请求日志里会有一行
`本次请求上下文 N 条；长期记忆 M 条`——N 是实际送给模型的历史条数，M 是记忆卡条数。



