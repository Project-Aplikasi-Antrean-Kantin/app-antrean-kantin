import zipfile
import sys
import struct

def get_local_file_offset(apk_path, entry):
    """Hitung offset data sebenarnya dari .so file di dalam ZIP"""
    with open(apk_path, 'rb') as f:
        f.seek(entry.header_offset)
        # Baca local file header
        signature = f.read(4)
        if signature != b'PK\x03\x04':
            return None
        f.seek(entry.header_offset + 26)
        fname_len = struct.unpack('<H', f.read(2))[0]
        extra_len = struct.unpack('<H', f.read(2))[0]
        # Offset data = header_offset + 30 (fixed header) + fname_len + extra_len
        data_offset = entry.header_offset + 30 + fname_len + extra_len
        return data_offset

def check_apk_alignment(apk_path):
    print(f"Checking: {apk_path}\n")
    ok = []
    issues = []
    compressed = []

    with zipfile.ZipFile(apk_path, 'r') as apk:
        for entry in apk.infolist():
            if not entry.filename.endswith('.so'):
                continue

            data_offset = get_local_file_offset(apk_path, entry)
            if data_offset is None:
                continue

            if entry.compress_type != 0:
                compressed.append(entry.filename)
            elif data_offset % 16384 == 0:
                ok.append((entry.filename, data_offset))
            else:
                issues.append({
                    'file': entry.filename,
                    'offset': data_offset,
                    '4kb': data_offset % 4096 == 0,
                    '16kb': False
                })

    # Print results
    for f, o in ok:
        print(f"✅ 16KB aligned (offset={o}): {f}")

    for f in compressed:
        print(f"⚠️  COMPRESSED: {f}")

    if issues:
        print("\n❌ NOT 16KB ALIGNED:")
        for i in issues:
            print(f"  - {i['file']}")
            print(f"    Offset : {i['offset']}")
            print(f"    4KB OK : {i['4kb']}")
            print(f"    16KB OK: {i['16kb']}")
    elif not compressed:
        print("\n✅ Semua .so files sudah 16KB aligned!")
    else:
        print("\n⚠️  Ada file compressed — pastikan useLegacyPackaging = false")

if __name__ == "__main__":
    apk = sys.argv[1] if len(sys.argv) > 1 else "build/app/outputs/flutter-apk/app-release.apk"
    check_apk_alignment(apk)