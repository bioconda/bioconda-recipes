#!/usr/bin/python

from setuptools import setup, find_packages
from os import listdir

pyfiles = [f.replace('.py', '') for f in listdir('.') if f.endswith('.py')]
setup(
    name='regional',
    version='1.1.2',
    description='simple manipulation and display of spatial regions in python',
    url='https://github.com/freeman-lab/regional',
    packages=find_packages(), py_modules=pyfiles)
