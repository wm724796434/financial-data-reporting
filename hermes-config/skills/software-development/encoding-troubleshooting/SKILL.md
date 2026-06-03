---
name: encoding-troubleshooting
description: Diagnose and fix cross-platform character encoding issues (乱码/mojibake) in filenames and files — especially Chinese GBK/GB2312 filenames in ZIP archives moved between Windows and Linux/WSL.
version: 1.0.0
author: agent
---

# Encoding Troubleshooting

Diagnose and fix garbled characters in filenames when working across Windows (GBK/GB2312) and Linux (UTF-8) environments.

## When to Load

- User reports garbled Chinese characters (`╜≡╩²╘┤┬δ`-style mojibake) in filenames
- "WinRAR解压乱码但WPS解压不乱码" — different software behaves differently
- Unzipping on WSL/Linux produces illegible filenames for Chinese-named files
- User asks why a ZIP file's directory/filenames look like random symbols

## Root Cause

ZIP file format stores filenames as **raw bytes** with no mandatory encoding declaration. The general-purpose bit 11 (0x0800 = "UTF-8 flag") was added in PKZIP 6.3.2 (2006) as a hint, but:

- Many Chinese Windows tools store filenames in GBK while leaving Bit 11=0
- Linux `unzip` defaults to CP437 (DOS OEM encoding) when Bit 11=0 → garbled output
- Different software uses different fallback strategies (see below)

## Diagnosis: Read ZIP Central Directory Raw Bytes

**Critical pitfall:** Python's `ZipFile(filename)` decodes bytes into a string *before you can inspect them*, destroying the original encoding. Always read raw bytes directly from the binary.

```python
import struct

with open('file.zip', 'rb') as f:
    data = f.read()

# Find End of Central Directory
eocd_sig = b'PK\x05\x06'
pos = data.rfind(eocd_sig)
cd_offset = struct.unpack_from('<I', data, pos + 16)[0]
cd_size   = struct.unpack_from('<I', data, pos + 12)[0]

cd = data[cd_offset : cd_offset + cd_size]
offset = 0
while offset < len(cd):
    sig = cd[offset:offset+4]
    if sig != b'PK\x01\x02':
        break
    
    gp_flag      = struct.unpack_from('<H', cd, offset + 8)[0]
    filename_len = struct.unpack_from('<H', cd, offset + 28)[0]
    extra_len    = struct.unpack_from('<H', cd, offset + 30)[0]
    comment_len  = struct.unpack_from('<H', cd, offset + 32)[0]
    
    filename_raw = cd[offset + 46 : offset + 46 + filename_len]
    is_dir = filename_raw.endswith(b'/')
    
    utf8_flag    = bool(gp_flag & 0x800)       # Bit 11
    
    print(f'Raw hex:     {filename_raw[:72].hex()}')
    print(f'UTF-8 flag:  {utf8_flag}')
    print(f'GBK decode:  {filename_raw.decode("gbk", errors="replace")}')
    print(f'CP437 dec:   {filename_raw.decode("cp437", errors="replace")}')
    print()
    
    entry_size = 46 + filename_len + extra_len + comment_len
    offset += entry_size
```

**Key diagnostic checks:**
1. **UTF-8 flag (Bit 11) = False** → no encoding declared, it's up to guesswork
2. **GBK decode yields correct Chinese** → original encoding was GBK
3. **CP437 decode yields `╜≡╩²╘┤┬δ`** → this is what unzip shows, confirming the problem

## Fixes

### Fix 1: unzip with encoding override (recommended)

```bash
sudo apt install unzip -y
unzip -O gbk file.zip -d output_dir/
```

The `-O` flag tells unzip what encoding to use for filename decoding.

### Fix 2: Python extraction (Python 3.12+)

```bash
python3 -c "
import zipfile
with zipfile.ZipFile('file.zip', 'r', metadata_encoding='gbk') as z:
    z.extractall('output_dir/')
"
```

### Fix 3: Python extraction (any version — manual byte wrangling)

Read raw names from the central directory, decode with GBK, then extract with corrected paths.

## Why Different Software Behave Differently

When Bit 11=0, every tool guesses the encoding differently:

| Software | Strategy | Result for GBK-named ZIP |
|----------|----------|--------------------------|
| **unzip (Linux)** | CP437 fallback (DOS legacy) | Garbled: `╜≡╩²╘┤┬δ` |
| **WinRAR** | System OEM code page (CP936 on zh-CN Windows) | Depends on system locale |
| **WPS** | Active encoding detection (tries GBK first) | Usually correct |
| **7-Zip / Bandizip** | Multi-encoding probe -> best match | Usually correct |

The fundamental difference: **rule-following** (use the system default for Bit 11=0) vs **active probing** (guess the encoding from the byte patterns).

## Pitfalls

- **Python `ZipFile.filename` is already corrupted** by the time you see it as a string. Never trust it for diagnosis — always read raw bytes from the binary.
- **`unzip -O` is not available on older unzip versions.** On macOS, install p7zip instead.
- **Same principle applies to other archive formats** — tar.gz, rar, and 7z with cross-platform Chinese filenames have the same root cause.
- **Do NOT blindly re-zip the files** after fixing the names — you'll create a ZIP with the same issue unless you explicitly specify UTF-8 encoding in the packing tool.

## See Also

- `references/zip-encoding-debug-detail.md` — worked example from a real session with full output
- `scripts/zip-encoding-diagnose.py` — reusable diagnostic script
