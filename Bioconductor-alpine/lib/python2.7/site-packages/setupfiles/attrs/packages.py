#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
from setuptools import find_packages

__all__ = ["packages", "package_dir", "package_data"]

cwd = os.getcwd()

# repo/
# repo/packages/
# repo/packages/pkgname1/*.py
# repo/packages/pkgname1/data/*
# repo/packages/pkgname2/*.py
# repo/packages/pkgname2/data/*

path = os.path.join(cwd, "packages")
if os.path.exists(path) and os.path.isdir(path):
    packages = find_packages('packages')
    if packages:
        package_dir = {'': 'packages'}
        package_data = dict()
        for package in packages:
            path = "packages/%s" % package
            #package_dir[package] = path
            data = '%s/data' % path
            if os.path.exists(data):
                package_data[package] = ['data/*']
