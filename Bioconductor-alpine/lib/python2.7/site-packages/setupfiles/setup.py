#!/usr/bin/env python
import distutils
import os
import sys
from setupfiles.attrs import packages, py_modules, scripts

__all__ = ["setup"]

cwd = os.getcwd()

_setup = distutils.core.setup

SETUP_DEBUG = "SETUP_DEBUG" in os.environ or sys.argv == 1

def debug(message):
    if SETUP_DEBUG:
        print(message)

def moduledict(module):
    """get module public objects dict"""
    kwargs = dict()
    for k in getattr(module, "__all__"):
        if hasattr(module, k):
            v = getattr(module, k)
            if v:
                kwargs[k] = v
    return kwargs


def setup(**attrs):
    debug("default attrs: %s" % attrs)
    # todo: entry_points
    if "packages" not in attrs:
        kwargs = moduledict(packages)
        attrs.update(kwargs)

    if "py_modules" not in attrs:
        kwargs = moduledict(py_modules)
        attrs.update(kwargs)

    if "scripts" not in attrs:
        kwargs = moduledict(scripts)
        attrs.update(kwargs)

    return _setup(**attrs)
