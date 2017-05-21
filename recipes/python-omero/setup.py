#!/usr/bin/python

from setuptools import setup, find_packages
from os import listdir

pyfiles = [f.replace('.py', '') for f in listdir('.') if f.endswith('.py')]
setup(name='Omero Python', version='5.3.2', description='OME (Open Microscopy Environment) develops open-source software and data format standards for the storage and manipulation of biological light microscopy data.', url='http://www.openmicroscopy.org/', packages=find_packages(), py_modules=pyfiles)
