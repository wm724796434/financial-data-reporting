#!/usr/bin/env python3
"""
Diagnose garbled Chinese filenames in ZIP archives.
Reads raw bytes from ZIP central directory to determine encoding.

Usage:
  python3 zip-encoding-diagnose.py path/to/file.zip
"""

import struct
import sys


def diagnose_zip(zip_path: str):
    """Read ZIP central directory raw bytes and diagnose encoding issues."""
    with open(zip_path, 'rb') as f:
        data = f.read()

    # End of Central Directory
    eocd_sig = b'PK\x05\x06'
    pos = data.rfind(eocd_sig)
    if pos < 0:
        print("Not a valid ZIP file (no EOCD signature)")
        return

    cd_offset = struct.unpack_from('<I', data, pos + 16)[0]
    cd_size = struct.unpack_from('<I', data, pos + 12)[0]
    cd = data[cd_offset:cd_offset + cd_size]

    print(f"ZIP file: {zip_path}")
    print(f"Total size: {len(data)} bytes")
    print(f"Central Directory: offset={cd_offset}, size={cd_size}")
    print()

    offset = 0
    entry_num = 0
    garbled_count = 0
    corrected_count = 0
    utf8_flag_set = 0

    while offset < len(cd):
        sig = cd[offset:offset+4]
        if sig != b'PK\x01\x02':
            break

        gp_flag = struct.unpack_from('<H', cd, offset + 8)[0]
        filename_len = struct.unpack_from('<H', cd, offset + 28)[0]
        extra_len = struct.unpack_from('<H', cd, offset + 30)[0]
        comment_len = struct.unpack_from('<H', cd, offset + 32)[0]

        filename_raw = cd[offset + 46: offset + 46 + filename_len]

        utf8_flag = bool(gp_flag & 0x800)
        is_dir = filename_raw.endswith(b'/')

        if utf8_flag:
            utf8_flag_set += 1

        # Try decodings
        try:
            raw_str = filename_raw.decode('cp437')
        except Exception:
            raw_str = repr(filename_raw)

        try:
            gbk_str = filename_raw.decode('gbk')
        except Exception:
            gbk_str = '<cannot decode as GBK>'

        try:
            utf8_str = filename_raw.decode('utf-8', errors='replace')
        except Exception:
            utf8_str = '<cannot decode as UTF-8>'

        # Detect if garbled: has CP437 box-drawing chars typical of GBK-misread
        has_garbled = any(0x2550 <= ord(c) <= 0x257F or 0x2500 <= ord(c) <= 0x25FF for c in raw_str)

        prefix = '[DIR] ' if is_dir else '[FILE]'

        if entry_num < 5 or has_garbled:
            print(f"{prefix} Raw hex: {filename_raw.hex()}")
            print(f"    CP437: {raw_str[:80]}")
            print(f"    GBK:   {gbk_str[:80]}")
            print(f"    UTF-8: {utf8_str[:80]}")
            print(f"    UTF-8 flag: {'YES' if utf8_flag else 'NO'}")
            print()

        if has_garbled:
            garbled_count += 1
        if gbk_str != '<cannot decode as GBK>' and not any(c in gbk_str for c in '\ufffd\ufffe\uffff'):
            corrected_count += 1

        entry_size = 46 + filename_len + extra_len + comment_len
        offset += entry_size
        entry_num += 1

    print(f"--- Summary ---")
    print(f"Total entries: {entry_num}")
    print(f"Entries with UTF-8 flag set: {utf8_flag_set}")
    print(f"Entries with garbled CP437: {garbled_count}")
    print(f"Entries that decode correctly as GBK: {corrected_count}")

    if garbled_count > 0 and corrected_count >= garbled_count * 0.8:
        print(f"\n=== DIAGNOSIS: ZIP filenames are GBK-encoded with Bit 11 = 0 ===")
        print(f"Fix: unzip -O gbk '{zip_path}' -d output_dir/")
    elif utf8_flag_set == 0 and corrected_count > 0:
        print(f"\n=== DIAGNOSIS: Some entries are GBK-encoded without UTF-8 flag ===")
        print(f"Fix: unzip -O gbk '{zip_path}' -d output_dir/")
    elif utf8_flag_set == entry_num:
        print(f"\n=== DIAGNOSIS: All entries have UTF-8 flag set — encoding should be fine ===")
    else:
        print(f"\n=== DIAGNOSIS: Mixed or inconclusive ===")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 zip-encoding-diagnose.py path/to/file.zip")
        sys.exit(1)
    diagnose_zip(sys.argv[1])
