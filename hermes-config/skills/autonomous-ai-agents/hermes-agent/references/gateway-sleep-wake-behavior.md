# Gateway Sleep/Wake Behavior

## Context

When running the Hermes Gateway on a laptop (or any machine that may enter sleep/suspend), users need to understand whether the gateway automatically reconnects after waking up. This document covers the general mechanism and the specific behavior of the Weixin (WeChat/iLink) platform.

## Sleep State Types: S3 vs S0 Modern Standby

**Before reasoning about recovery, determine which sleep type your system uses.** This is the single most important factor.

### S3 Sleep (Traditional)

On older laptops and desktops:
- RAM stays powered (keeps process memory intact)
- **CPU is off** — all processes frozen
- **Network interface is off**
- Every wake is a full resume from RAM → processes thaw → network reconnects

The rest of this document assumes S3 sleep — the sections below describe how recovery works after a traditional suspend/resume cycle.

### S0 Modern Standby (Modern Standby / Connected Standby)

On newer laptops (Intel 8th-gen+, AMD Ryzen 6000+, Snapdragon):
- The system stays in S0 (working state) at low power
- **CPU continues running** (at reduced frequency)
- **Network stays connected**
- Background processes continue to execute
- **The gateway may never actually freeze** — it just keeps polling

This means **"sleep" ≠ gateway downtime** on Modern Standby systems. The gateway can continue receiving and responding to messages while the lid is closed and the screen is off.

### How to detect which sleep state your system supports

From within WSL:

```bash
powershell.exe -Command "powercfg /a"
```

Look for:
- `待机 (S0 低电量待机) 连接的网络` / `Standby (S0 Low Power Idle) Connected Network` → **Modern Standby with network** ✅ Gateway should work through sleep
- `待机 (S3)` / `Standby (S3)` → Traditional sleep, gateway will freeze
- `待机 (S0 低电量待机)` without "Connected" → Modern Standby but network may disconnect

### How to check current sleep/power configuration

```bash
# Active power scheme
powershell.exe -Command "powercfg /getactivescheme"

# All settings for the active scheme
powershell.exe -Command "powercfg /q <GUID>"

# Check lid close action (registry deep-dive)
# ACSettingIndex = 1 means Sleep, DCSettingIndex = 1 means Sleep
powershell.exe -Command "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\4f971e89-eebd-4455-a8de-9e59040e7347\5ca83367-6e45-459f-a27b-476b1d01c936\DefaultPowerSchemeValues\<GUID>\' -Name ACSettingIndex"
powershell.exe -Command "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\4f971e89-eebd-4455-a8de-9e59040e7347\5ca83367-6e45-459f-a27b-476b1d01c936\DefaultPowerSchemeValues\<GUID>\' -Name DCSettingIndex"
```

### Practical guidance

| System has | User closes lid | Gateway behavior | User needs to |
|---|---|---|---|
| S0 Modern Standby (Connected) | "Sleep" but CPU/network stay alive | Keeps running ✅ | Nothing — just test it once |
| S3 Traditional Sleep | Genuine suspend, everything frozen | Freezes, recovers on wake ✅ | Nothing — auto-recovers |
| S3 with Hibernate after N minutes | Full power-off after N min | Process killed ❌ | Set hibernate to "never" |

**Pitfall — "sleep" means different things:** On Modern Standby systems, the user setting "sleep after 30 minutes" doesn't actually put the system to sleep in the traditional sense — it's a low-power idle that keeps the gateway running. If the user reports "it doesn't work after sleep," first check `powercfg /a` to confirm it's actually S3 sleep (where the CPU stops) before debugging the gateway's recovery logic.

## General Principle (Applies to S3 Sleep)

This section describes the recovery path for systems that genuinely suspend (S3). The Hermes Gateway is a **multi-platform process** — each platform adapter runs independently in its own asyncio task:

```
gateway run → asyncio loop → platform adapter A's poll loop
                            → platform adapter B's poll loop
                            → ... etc.
```

When the system suspends (S3):
- The entire Python process is **frozen in memory** (all asyncio tasks suspended)
- The network interface goes down — all TCP connections and HTTP sessions break
- iLink API servers timeout on the server side

When the system resumes:
- The Python process is **unfrozen** — asyncio tasks resume where they were suspended
- Network comes back
- Each platform adapter's next attempt to interact with its API **will fail** (broken socket / HTTP timeout)
- The adapter's error handling kicks in and retries

## Weixin (WeChat/iLink) Platform — Long-Poll Design

The WeChat adapter uses **HTTP long-polling**, not a persistent TCP connection. This is the key reason sleep/wake is handled gracefully.

### Source: `gateway/platforms/weixin.py`

```python
# Line 7 (docstring):
# "Long-poll getupdates drives inbound delivery."

# Line 86-88 — timing constants
LONG_POLL_TIMEOUT_MS = 35_000       # 35s per poll
API_TIMEOUT_MS = 15_000              # general API timeout

# Line 91-93 — retry logic
MAX_CONSECUTIVE_FAILURES = 3
RETRY_DELAY_SECONDS = 2
BACKOFF_DELAY_SECONDS = 30
```

### The polling loop (lines 1313-1371)

```python
async def _poll_loop(self) -> None:
    sync_buf = _load_sync_buf(...)
    timeout_ms = LONG_POLL_TIMEOUT_MS
    consecutive_failures = 0

    while self._running:
        try:
            response = await _get_updates(
                self._poll_session, ...,
                timeout_ms=timeout_ms,
            )
            # ... process messages ...
            consecutive_failures = 0  # reset on success

        except asyncio.CancelledError:
            break  # clean shutdown

        except Exception as exc:
            consecutive_failures += 1
            logger.error("[%s] poll error (%d/%d): %s", ...)
            await asyncio.sleep(
                BACKOFF_DELAY_SECONDS if consecutive_failures >= MAX_CONSECUTIVE_FAILURES
                else RETRY_DELAY_SECONDS
            )
            if consecutive_failures >= MAX_CONSECUTIVE_FAILURES:
                consecutive_failures = 0  # reset counter after backoff
```

### Sleep/wake cycle walkthrough

1. **Before sleep**: `_get_updates()` is awaiting a long-poll HTTP response (35s timeout)
2. **System sleeps**: The coroutine is frozen mid-`await`. Network goes down.
3. **System wakes**: The coroutine resumes. The in-flight HTTP request has a stale socket.
4. **~15s later** (`API_TIMEOUT_MS`): aiohttp raises a timeout or connection error.
5. The `except Exception` catches it → `consecutive_failures += 1`
6. Waits **2s** (`RETRY_DELAY_SECONDS`) → fires a new `_get_updates()` request
7. Network is back → request succeeds → `consecutive_failures = 0`
8. **Normal operation resumes** ✅

### Session expiry

If the iLink session expired during sleep (e.g. slept for hours), the adapter handles it explicitly (line 1335-1340):

```python
if (ret == SESSION_EXPIRED_ERRCODE or errcode == SESSION_EXPIRED_ERRCODE
        or _is_stale_session_ret(ret, errcode, response.get("errmsg"))):
    logger.error("[%s] Session expired; pausing for 10 minutes", self.name)
    await asyncio.sleep(600)  # wait 10 minutes before retry
    consecutive_failures = 0
    continue
```

After 10 minutes, it resumes polling. If the session is still expired, it repeats.

### Failed-state reset

The `consecutive_failures` counter resets to 0 after hitting the backoff threshold (line 1352-1353), so a single sleep event doesn't permanently degrade retry behavior — the next successful request resets everything.

## Comparison: Old Way (Terminal) vs New Way (systemd service)

| Aspect | Terminal process | systemd service (`hermes-gateway.service`) |
|--------|----------------|-------------------------------------------|
| Sleep recovery | Same process recovery ✅ | Same process recovery ✅ |
| Process crash after wake | Terminal dies → gateway lost ❌ | `Restart=always` auto-restarts ✅ |
| Visibility | User sees terminal → knows state | `/platforms` or `systemctl --user status` |

The real difference is **crash survival** — if the gateway process crashes after waking (e.g. segfault, OOM, corrupted state), systemd restarts it automatically. A terminal process would be gone until the user notices and re-runs `hermes gateway run`.

## Diagnosis Commands

```bash
# Check gateway process status
systemctl --user status hermes-gateway.service

# View recent gateway logs
journalctl --user -u hermes-gateway.service --since "10 minutes ago" --no-pager

# Or check the file log
tail -50 ~/.hermes/logs/gateway.log

# Platform-specific status (from within Hermione session)
/platforms
# or
systemctl --user is-active hermes-gateway.service
```

## Full Boot Dependency Chain

For reboots (not sleep), the chain is:

```
Windows boot → user login
  → Registry Run key executes wsl.exe -d Ubuntu
    → WSL instance starts
      → systemd --user starts
        → hermes-gateway.service (enabled) starts
          → gateway poll loops begin
```

Verify each layer:

```bash
# Windows side: check WSL is running
wsl.exe -l -v

# WSL side: check systemd service
systemctl --user is-active hermes-gateway.service
systemctl --user status hermes-gateway.service
```
