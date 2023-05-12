#!/usr/bin/env python

import bz2
import difflib
import json
import os
import urllib

from gen_patch_json import _gen_new_index, _gen_patch_instructions, SUBDIRS

from conda_build.index import _apply_instructions

CACHE_DIR = os.environ.get(
    "CACHE_DIR",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "cache")
)
BASE_URL = "https://conda.anaconda.org/bioconda"


def show_record_diffs(subdir, ref_repodata, new_repodata):
    for name, ref_pkg in ref_repodata["packages"].items():
        new_pkg = new_repodata["packages"][name]
        # license_family gets added for new packages, ignore it in the diff
        ref_pkg.pop("license_family", None)
        new_pkg.pop("license_family", None)
        if ref_pkg == new_pkg:
            continue
        print(f"{subdir}::{name}")
        ref_lines = json.dumps(ref_pkg, indent=2).splitlines()
        new_lines = json.dumps(new_pkg, indent=2).splitlines()
        for ln in difflib.unified_diff(ref_lines, new_lines, n=0, lineterm=''):
            if ln.startswith('+++') or ln.startswith('---') or ln.startswith('@@'):
                continue
            print(ln)


def do_subdir(subdir, raw_repodata_path, ref_repodata_path):
    with bz2.open(raw_repodata_path) as fh:
        raw_repodata = json.load(fh)
    with bz2.open(ref_repodata_path) as fh:
        ref_repodata = json.load(fh)
    new_index = _gen_new_index(raw_repodata, subdir)
    instructions = _gen_patch_instructions(raw_repodata['packages'], new_index, subdir)
    new_repodata = _apply_instructions(subdir, raw_repodata, instructions)
    show_record_diffs(subdir, ref_repodata, new_repodata)


def download_subdir(subdir, raw_repodata_path, ref_repodata_path):
    raw_url = f"{BASE_URL}/{subdir}/repodata_from_packages.json.bz2"
    print("Downloading:", raw_url)
    urllib.request.urlretrieve(raw_url, raw_repodata_path)
    ref_url = f"{BASE_URL}/{subdir}/repodata.json.bz2"
    print("Downloading:", ref_url)
    urllib.request.urlretrieve(ref_url, ref_repodata_path)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(
        description="show repodata changes from the current gen_patch_json")
    parser.add_argument(
        '--subdirs', nargs='*', default=None,
        help='subdir(s) show, default is all')
    parser.add_argument(
        '--use-cache', action='store_true',
        help='use cached repodata files, rather than downloading them')
    args = parser.parse_args()

    if args.subdirs is None:
        subdirs = SUBDIRS
    else:
        subdirs = args.subdirs

    for subdir in subdirs:
        subdir_dir = os.path.join(CACHE_DIR, subdir)
        if not os.path.exists(subdir_dir):
            os.makedirs(subdir_dir)
        raw_repodata_path = os.path.join(subdir_dir, "repodata_from_packages.json.bz2")
        ref_repodata_path = os.path.join(subdir_dir, "repodata.json.bz2")
        if not args.use_cache:
            download_subdir(subdir, raw_repodata_path, ref_repodata_path)
        do_subdir(subdir, raw_repodata_path, ref_repodata_path)
