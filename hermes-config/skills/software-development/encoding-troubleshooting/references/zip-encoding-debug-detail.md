# ZIP文件中文乱码：真实案例分析

来自 2026-05-20 会话的真实调试过程，记录每一步的思考和数据。

## 场景

用户在 `E:\workspace`（WSL 挂载点 `/mnt/e/workspace`）下有一个 `金数源码.zip`，解压后目录名和文件名全部显示为乱码。

## 第一步：确认文件存在 & 基本信息

```bash
ls -la '/mnt/e/workspace/金数源码.zip'
# -r-xr-xr-x 1 wm wm 353572 May 20 16:06 金数源码.zip
```

## 第二步：用 Python 列出 ZIP 内容

```python
import zipfile
zpath = '/mnt/e/workspace/金数源码.zip'
with zipfile.ZipFile(zpath, 'r') as z:
    for info in z.infolist():
        print(repr(info.filename))
```

输出：
```
'╜≡╩²╘┤┬δ/'
'╜≡╩²╘┤┬δ/╝╙╣ñ▓π┤µ┤ó/'
'╜≡╩²╘┤┬δ/╝╙╣ñ▓π┤µ┤ó/bsp_job_pbocd_table.prc'
'╜≡╩²╘┤┬δ/╝╙╣ñ▓π┤µ┤ó/bsp_sp_js_101_jrjgfz.prc'
...
```

看到 `╜≡╩²╘┤┬δ` 这样的符号 — 这是 **CP437 解码 GBK 字节** 的典型特征：
- GBK 汉字编码范围在高字节区（0x80-0xFE）
- CP437 将这些字节映射成了带重音符号的拉丁字母和框线字符

## 第三步：直接从二进制读取中央目录

Python `ZipFile` 已经把文件名解压成字符串了（已损坏），必须绕开它直接从 ZIP 二进制读取：

```python
import struct

with open(zpath, 'rb') as f:
    data = f.read()

eocd_sig = b'PK\x05\x06'
pos = data.rfind(eocd_sig)
cd_offset = struct.unpack_from('<I', data, pos + 16)[0]
cd_size = struct.unpack_from('<I', data, pos + 12)[0]
cd = data[cd_offset:cd_offset + cd_size]
```

中央目录的每个条目（Central Directory Entry）以 `PK\x01\x02` 开头。

关键字段：
- `offset+28` (2字节): 文件名长度
- `offset+30` (2字节): 额外字段长度
- `offset+32` (2字节): 注释长度
- `offset+8` (2字节): 通用标志位（Bit 11 = 0x0800 = UTF-8标志）
- `offset+46` 开始: 文件名原始字节

## 第四步：分析结果

```
--- Entry 0 ---
  [目录]
  原始字节 (hex): bdf0cafdd4b4c2eb2f
  GBK 解码: 金数源码/
  CP437 解码: ╜≡╩²╘┤┬δ/
  UTF-8 标志位: 未设置 (0)
```

确认：
1. **Bit 11 = 0** — 打包工具没有设置 UTF-8 标志
2. **原始字节是 GBK 编码** — `bdf0 cafd d4b4 c2eb` = "金数源码"
3. **CP437 decode 正好是乱码的样子** — 和用 unzip 看到的完全一致

## 第五步：验证其他条目

所有中文路径和文件名都相同的情况：
- `加工层存储` → `╝╙╣ñ▓π┤µ┤ó`
- `加工层特殊处理` → `╝╙╣ñ▓π╠╪╩Γ┤ª└φ`
- `应用层特殊处理` → `╙ª╙├▓π╠╪╩Γ┤ª└φ`

长中文文件名示例：
```
当贷款展期到期日期不为空且为固定利率贷款时，贷款利率重新定价日应等于贷款展期到期日期.sql
```

## 根因总结

| 层面 | 发现 |
|------|------|
| 编码 | 文件名以 GBK (CP936) 编码存储 |
| 标志 | Bit 11 (UTF-8 flag) = 0 |
| 标准 | ZIP 规范没有强制编码声明，Bit 11 只是 hints |
| 时间 | PKZIP 6.3.2 (2006) 才引入 Bit 11，老工具不设 |
| 后果 | Linux unzip 用 CP437 解码 → 乱码 |

## 软件行为对比

用户报告：**WinRAR 解压乱码，WPS 解压不乱码**

- **WPS** 作为国产软件，主动探测编码：试 GBK → 成功（字节都合法）→ 锁定 GBK
- **WinRAR** 走规则：Bit 11=0 → 用系统 OEM 代码页 → 如果系统区域非中文或用英文版 WinRAR，fallback 到 CP437

所以这不是任何一个软件的"bug"，而是 ZIP 格式的历史设计缺陷 + 不同软件的编码推断策略差异。
