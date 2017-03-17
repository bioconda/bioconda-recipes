#!/usr/bin/python

from setuptools import setup, find_packages
  
setup(name='Omero Python', version='5.2.7', description='OME (Open Microscopy Environment) develops open-source software and data format standards for the storage and manipulation of biological light microscopy data.', url='http://www.openmicroscopy.org/', packages=find_packages(), py_modules=['omero_version'])
