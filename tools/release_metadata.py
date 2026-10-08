#!/usr/bin/env python3
"""Validate release metadata; stdlib only. Run before every release."""
import argparse
import json
import re
import sys
from pathlib import Path

MOD_ID = "pikachu_true_potential"
SEMVER = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
SECTION = re.compile(r"(?m)^## \[([0-9]+\.[0-9]+\.[0-9]+)\](?:\s+-\s+[^\n]+)?\s*$")


def validate(root: Path, requested_version: str | None = None) -> tuple[str, str, str]:
    manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
    version = str(manifest.get("version", ""))
    if manifest.get("id") != MOD_ID:
        raise ValueError(f"manifest id must be {MOD_ID}")
    if not SEMVER.fullmatch(version):
        raise ValueError(f"invalid manifest version: {version!r}")
    if requested_version is not None and requested_version != version:
        raise ValueError(f"release version {requested_version!r} must equal manifest version {version!r}")
    changelog = (root / "CHANGELOG.md").read_text(encoding="utf-8")
    matches = list(SECTION.finditer(changelog))
    if not matches:
        raise ValueError("CHANGELOG.md has no version sections")
    versions = [m.group(1) for m in matches]
    if len(versions) != len(set(versions)):
        raise ValueError("CHANGELOG.md contains duplicate version sections")
    if versions[0] != version:
        raise ValueError(f"top CHANGELOG.md version {versions[0]} must equal manifest version {version}")
    current = changelog[matches[0].end(): matches[1].start() if len(matches) > 1 else len(changelog)].strip()
    if not current or not re.search(r"(?m)^\s*-\s+\S", current):
        raise ValueError(f"CHANGELOG.md [{version}] must contain at least one change bullet")
    tag = f"v{version}"
    zip_name = f"{MOD_ID}-{version}.zip"
    return version, tag, zip_name


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--version", help="release version (must match manifest.json)")
    parser.add_argument("--github-output", type=Path, help="append validated outputs for GitHub Actions")
    args = parser.parse_args()
    try:
        version, tag, zip_name = validate(args.root, args.version)
    except (ValueError, OSError, json.JSONDecodeError) as exc:
        print(f"::error::{exc}", file=sys.stderr)
        return 1
    print(f"Validated manifest, changelog, tag and ZIP: {version} / {tag} / {zip_name}")
    if args.github_output:
        with args.github_output.open("a", encoding="utf-8") as output:
            output.write(f"version={version}\ntag={tag}\nzip_name={zip_name}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
