#!/usr/bin/python

from setuptools import setup, find_packages
from os import listdir

pyfiles = [f.replace('.py', '') for f in listdir('.') if f.endswith('.py')]
setup(
    name='showit',
    version='1.1.4',
    description='simple and sensible display of images in python',
    url='https://github.com/freeman-lab/showit',
    packages=find_packages(), py_modules=pyfiles,
    include_package_data=True)
