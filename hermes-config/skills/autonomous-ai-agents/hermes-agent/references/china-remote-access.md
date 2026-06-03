# 中国网络环境下 Hermes 移动端远程访问方案

## 问题场景

- 电脑在 NAT 后，无公网 IP
- 手机使用移动 5G 网络，与电脑不在同一网络
- 用户在国内，境外服务连通性不稳定
- 目标：手机端操作 Hermes

## 连通性测试数据（2026-05-17，中国家庭宽带环境）

| 服务 | 类型 | HTTP状态 | 延迟 | 可用性 |
|------|------|----------|------|--------|
| login.tailscale.com | 虚拟组网 | 超时（10s无响应） | N/A | ❌ 不可用 |
| my.zerotier.com | 虚拟组网 | 200 | 7.8s | ⚠️ 可用但偏慢 |
| ngrok.com | 内网穿透 | 200 | 1.2s | ✅ 可用 |
| ilinkai.weixin.qq.com | 微信 iLink API | 404（正常，根路径无页面） | 0.15s | ✅ 推荐 |

## 首选方案：Hermes Gateway + 微信（iLink Bot）

### 为什么这是首选？

1. **零网络穿透** —— 电脑和手机都主动连接微信服务器（出站连接），微信服务器天然解决通信问题
2. **零公网依赖** —— 不需要公网 IP、不需要云服务器、不需要域名
3. **零额外 App** —— 手机端直接用微信，不需要安装任何新软件
4. **腾讯官方接口** —— 使用 iLink Bot API（`ilinkai.weixin.qq.com`），国内网络 0.15s 延迟
5. **配置极简** —— 安装 2 个 Python 依赖 → 运行 setup wizard → 扫码登录 → 完成

### 接入原理

微信使用腾讯官方的 **iLink Bot API**，可以直接将个人微信账号绑定为 Bot：

- 不需要申请微信公众号、不需要企业微信资质
- 不需要 API Key 或 Secret
- 终端显示二维码 → 用手机微信扫码确认 → 自动下发 token 并保存到本地
- 支持私聊和群聊，支持文字、图片、文件

通信架构：

```
手机微信 App ──→ 微信 iLink 服务器 ←── 电脑 Hermes Gateway（长轮询）
                     （腾讯国内服务器）
```

### 部署步骤

**1. 安装依赖**

```bash
pip install aiohttp cryptography
```

**2. 启动 Gateway 配置向导**

```bash
hermes gateway setup
```

在交互式界面中选择 **Weixin（微信）** 平台。系统会自动触发 iLink QR 码登录——终端显示二维码，用手机微信扫描并确认。

成功后终端输出 `微信连接成功，account_id=...`，token 保存在 `~/.hermes/weixin/accounts/`。

**3. 启动 Gateway**

```bash
hermes gateway start
```

Gateway 在后台持续运行，通过长轮询等待微信消息。用 `hermes gateway status` 查看状态。

**4. 使用**

在手机微信中找到绑定的 Bot 联系人，直接发消息即可操作 Hermes。群聊中将 Bot 拉入群后 @它 也能使用。

### 依赖与环境说明

- 微信适配器的运行时依赖：`aiohttp`（HTTP 通信）+ `cryptography`（AES 加密，用于媒体文件传输）
- 依赖检查函数：`check_weixin_requirements()` 在 `gateway/platforms/weixin.py` 中定义
- 账户凭证存储：`~/.hermes/weixin/accounts/<account_id>.json`（权限 0o600）
- 上下文 token 缓存：`~/.hermes/weixin/accounts/<account_id>.context-tokens.json`
- 配置环境变量：`WEIXIN_TOKEN`、`WEIXIN_ACCOUNT_ID`、`WEIXIN_BASE_URL`、`WEIXIN_CDN_BASE_URL`、`WEIXIN_DM_POLICY`、`WEIXIN_GROUP_POLICY`

### 局限性

- 界面是微信聊天窗口，不是独立的可视化 App 页面
- 如果需要定制化的可视化页面，可以在微信方案跑通后，利用 Gateway 的 **API Server 模式** 叠加 PWA 页面（两种方式可以共存）

---

## ⚠️ 关于 @im.bot 的关键事实（重要！）

### @im.bot 不是可搜索的微信号

@im.bot（如 `06b32da843be@im.bot`）是一个 **iLink Bot API 身份**，不是普通微信账号。**在微信中搜索是搜不到的**——不要告诉用户去搜索 @im.bot。

❌ 错误指导："在微信里搜索 @im.bot"
✅ 正确做法：运行 `hermes gateway setup` 生成二维码，扫码绑定

### 连接机制：QR 码授权，不是"加好友"

```
用户终端运行 hermes gateway setup
  → 选择 Weixin 平台
  → Hermes 调用 iLink API: GET ilink/bot/get_bot_qrcode?bot_type=3
  → 返回两个值：qrcode（hex token）+ qrcode_img_content（可扫描 URL）
  → 终端显示二维码（ASCII图案 + URL）
  → 用户用手机微信扫描二维码
  → 微信弹出"确认登录"界面，用户点确认
  → iLink 返回：ilink_bot_id（Bot账号）、bot_token（令牌）、ilink_user_id（用户微信ID）
  → 凭据保存到 ~/.hermes/weixin/accounts/<account_id>.json
  → 连接成功
```

**关键源码位置：** `gateway/platforms/weixin.py::qr_login()`（约第1041行）
**API 端点：** `EP_GET_BOT_QR = "ilink/bot/get_bot_qrcode"`、`EP_GET_QR_STATUS = "ilink/bot/get_qrcode_status"`
**QR 码有效期：** 约 8 分钟，自动刷新最多 3 次

### 三条不可突破的限制

1. **Bot 只能回复，不能主动发起。** 用户必须先扫码建立会话，Bot 才能在该会话中回复。`send_message` 会返回 `"Could not resolve '<user_id>' on weixin"` 错误。
2. **@im.bot 不在用户的微信通讯录中。** PC 端微信不会显示该会话（已知 iLink API 限制）。
3. **@im.bot 通常无法被邀请进普通微信群。** `WEIXIN_GROUP_POLICY` 设置了也没用——iLink 端可能根本不投递群聊事件。

### 如何让另一个人（如毛建福）连接 Bot

要让另一个人也能和 Bot 对话：

1. **生成二维码**：运行 `hermes gateway setup`，选择 Weixin，终端会打印一个二维码 URL
2. **把二维码 URL 发给对方**：对方用微信扫码 → 确认 → 建立会话
3. **验证**：扫码后对方给 Bot 发条消息，如果 Gateway 在线，Bot 会回复

**原理：** iLink Bot 的二维码不是一次性注册码——任何人扫码都可以将自己的微信 ID 绑定到 Bot 的会话白名单中。上面 `qr_login()` 的源码中，二维码被轮询直至 `status == "confirmed"`，任何用户扫码确认都可以完成绑定。

### 与睡眠相关的问题

Gateway 使用 HTTP 长轮询（`getupdates`，35 秒超时），不是持久 TCP 连接。睡眠/唤醒后：
- **S0 Modern Standby（现代待机）**：网络不断、CPU 不冻——Gateway 可能正常运行，睡眠再唤醒后连接自动恢复
- **S3 传统睡眠**：WSL 进程冻结 → 长轮询超时 → 唤醒后自动重试恢复
- **关机**：必须配 WSL 开机自启，才能自动拉起 Gateway

检测睡眠状态的 PowerShell 命令：`powercfg /a`

> 详细源码分析和恢复时间线见 `references/gateway-sleep-wake-behavior.md`

---

## 备选方案：ngrok + Python HTTP 桥接 + PWA

适用于需要独立可视化页面（非聊天界面）的场景。

```
┌──────────────────┐         ngrok 公网隧道          ┌──────────────────┐
│  安卓手机         │                                │  WSL2 (电脑)      │
│                  │  https://xxx.ngrok-free.app ──▶ │                  │
│  PWA Web App ────┼── HTTP POST /chat ────────────▶ │  FastAPI :8080   │
│  (浏览器打开)     │                                │  ↓ hermes chat -q │
│                  │ ◀──── JSON 响应 ──────────────── │  ↓ 返回结果       │
└──────────────────┘                                └──────────────────┘
```

优点：手机浏览器直接打开，可自定义界面，支持 PWA（添加到主屏幕全屏体验）
缺点：免费版 ngrok URL 每次重启会变，多一个故障点（ngrok 隧道），需要自行开发桥接服务和前端页面

---

## 备选方案：frp + 轻量云服务器（最稳定，但有成本）

需要一台有公网 IP 的云服务器（阿里云/腾讯云最低配约 50元/月）。
优点：完全可控、URL 不变化、可绑定域名、带宽和稳定性有保障。
适用于需要长期 7×24 稳定运行的场景。

---

## 备选方案：ZeroTier（虚拟组网）

跟 Tailscale 同类但国内可用（测试延迟 7.8s，偏慢）。
手机需要安装 ZeroTier App，通过虚拟 IP 访问电脑上的服务。

---

## 测试连通性的通用方法

```bash
# 测试一个服务是否可从当前网络访问
curl -s -o /dev/null -w "HTTP: %{http_code} 耗时: %{time_total}s\n" \
  --connect-timeout 8 https://目标URL
```

超时或 HTTP 000 表示不可达；HTTP 200 或 404（API 根路径通常返回 404 是正常的，只要不超时即表示可达）；7-8 秒以上的延迟意味着体验会很差。
