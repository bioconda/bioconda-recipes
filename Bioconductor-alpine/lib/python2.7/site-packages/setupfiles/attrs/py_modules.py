#!/usr/bin/env python
import os

__all__ = ["package_dir","py_modules"]

cwd = os.getcwd()

def listnames(path):
    listdir = os.listdir(path)
    for l in listdir:
        if os.path.splitext(l)[1] != ".py":
            continue
        fullpath = os.path.join(path, l)
        if not os.path.isfile(fullpath):
            continue
        yield l.replace(".py", "")


path = os.path.join(cwd, "py_modules")
if os.path.exists(path) and os.path.isdir(path):
    py_modules = list(listnames(path))
    if py_modules:
        package_dir = {'': "py_modules"}

