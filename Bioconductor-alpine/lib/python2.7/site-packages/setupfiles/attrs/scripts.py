#!/usr/bin/env python
import os

__all__ = ["scripts"]

cwd = os.getcwd()

def valid_script_name(name):
    if name == ".DS_Store":
        return False
    if " " in name:  # skip filename with ' ' space
        return False
    if ".txt" in name:  # skip .txt files
        return False
    return True

def listnames(path):
    listdir = os.listdir(path)
    for l in listdir:
        if not valid_script_name(l):
            continue
        dst = os.path.join("/usr/local/bin/%s" % l)
        if os.path.exists(dst) and not os.path.isfile(dst):
            raise OSError("ERROR: %s EXISTS and NOT FILE" % dst)
        fullpath = os.path.join(path, l)
        if os.path.isfile(fullpath):
            yield os.path.relpath(fullpath,cwd)


dirname = "bin"
path = os.path.join(cwd, dirname)
if os.path.exists(path) and os.path.isdir(path):
    scripts = list(listnames(path))

