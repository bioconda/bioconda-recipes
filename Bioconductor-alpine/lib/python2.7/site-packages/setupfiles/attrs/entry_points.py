#!/usr/bin/env python
import os

__all__ = ["entry_points"]

cwd = os.getcwd()

# ./entry_points.txt
path = os.path.join(cwd, "entry_points.txt")
if os.path.exists(path) and os.path.isfile(path):
    entry_points =  open(path).read().splitlines()

if os.environ.get("ENTRY_POINTS",None):
    entry_points+=os.environ.get("ENTRY_POINTS").splitlines()
