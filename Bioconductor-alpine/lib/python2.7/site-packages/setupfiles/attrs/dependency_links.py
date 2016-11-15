#!/usr/bin/env python
import os

__all__ = ["dependency_links"]

cwd = os.getcwd()

dependency_links = []
filenames = ["dependency_links.txt", "dependency.txt"]
for filename in filenames:
    path = os.path.join(cwd, filename)
    dependency_links += open(path).read().splitlines()

if os.environ.get("DEPENDENCY_LINKS",None):
    dependency_links+=os.environ.get("DEPENDENCY_LINKS").splitlines()
