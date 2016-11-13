#!/usr/bin/env python
# checks requirements BEFORE install (python install setup.py)
#
# ERRORS (depends on setiptools version):
# a) error: Could not find required distribution <name>
# b) SandboxViolation: open('name.egg-info/dependency_links.txt', 'wb') {}
#
# fix:
# pip install -r requirements.txt (REQUIRED)
# python install setup.py

import os

__all__ = ["install_requires"]

cwd = os.getcwd()

filenames = ["install_requires.txt", "requires.txt", "requirements.txt"]
for filename in filenames:
    path = os.path.join(cwd, filename)
    if os.path.exists(path):
        install_requires = open(path).read().splitlines()

if os.environ.get("INSTALL_REQUIRES",None):
    install_requires+=os.environ.get("INSTALL_REQUIRES").splitlines()
