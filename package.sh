#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
python3 - "$ROOT" <<'PY'
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo
import json
import sys

root = Path(sys.argv[1])
metadata = json.loads((root / "metadata.json").read_text(encoding="utf-8"))
plugin = metadata["KPlugin"]
output_dir = root / "dist"
output_dir.mkdir(exist_ok=True)
output = output_dir / f"control-center-{plugin['Version']}.plasmoid"

sources = [root / name for name in ("metadata.json", "LICENSE", "NOTICE")]
sources.extend(path for path in (root / "contents").rglob("*") if path.is_file())

with ZipFile(output, "w", compression=ZIP_DEFLATED, compresslevel=9) as archive:
    for path in sorted(sources):
        relative = path.relative_to(root).as_posix()
        info = ZipInfo(relative, date_time=(1980, 1, 1, 0, 0, 0))
        info.compress_type = ZIP_DEFLATED
        info.external_attr = (0o100644 & 0xFFFF) << 16
        archive.writestr(info, path.read_bytes(), compress_type=ZIP_DEFLATED, compresslevel=9)

print(output)
PY
