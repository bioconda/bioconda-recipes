#!/usr/bin/python

from setuptools import setup, find_packages
from os import listdir

pyfiles = [f.replace('.py', '') for f in listdir('.') if f.endswith('.py')]
setup(
    name='slicedimage',
    version='0.0.1',
    description='sliced imaging data',
    url='https://github.com/spacetx/slicedimage',
    packages=find_packages(), py_modules=pyfiles)
