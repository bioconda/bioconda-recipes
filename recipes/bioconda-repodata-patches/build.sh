#!/bin/bash
set -ex
ls -l
./gen_patch_json.py
ls -l $PREFIX
