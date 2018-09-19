#!/usr/bin/env python
# Small wrapper script for weeder2, which needs the FreqFiles directory
# where it is executed. This script allows running weeder2 from anywhere.
import os
import sys
import argparse
import subprocess as sp

# Weeder install dir
weeder_dir = os.path.realpath(os.path.join(os.path.dirname(__file__), "..", "share", "weeder2"))
weeder_exe = "weeder2"

weeder_help = sp.check_output(
        os.path.join(weeder_dir, weeder_exe),
        stderr=sp.STDOUT).decode()
parser = argparse.ArgumentParser()
parser.add_argument("-f", dest="fname")
args, unknownargs = parser.parse_known_args()
if not args.fname:
    print(weeder_help)
    sys.exit()

fname = os.path.abspath(args.fname)
rest = " ".join(unknownargs)
cmd = "./{} -f {} {}".format(weeder_exe, fname, rest)
sys.exit(sp.call(cmd, shell=True, cwd=weeder_dir))
