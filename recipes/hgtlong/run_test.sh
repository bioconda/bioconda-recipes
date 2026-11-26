#!/usr/bin/env bash
set -euo pipefail
python -m unittest discover -s tests -v
python demo/run_demo.py --outdir demo-default
python demo/run_demo.py --outdir demo-min1000 --min-hgt-length 1000
python demo/run_demo.py --outdir demo-min1001 --min-hgt-length 1001
