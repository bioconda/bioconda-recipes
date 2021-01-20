#!/usr/bin/env python
import argparse
from os.path import exists

parser = argparse.ArgumentParser(description="This looks for blacklisted recipes that have been deleted.")
args = parser.parse_args()

for line in open("build-fail-blacklist"):
    if line.startswith("recipes/"):
        if not exists(line.strip()):
            print(line.strip())
