#!/usr/bin/python

from setuptools import setup, find_packages
from os import listdir

pyfiles = [f.replace('.py', '') for f in listdir('.') if f.endswith('.py')]
setup(
    name='starfish',
    version='0.0.4',
    description='a standardized analysis pipeline for image-based transcriptomics',
    url='https://github.com/spacetx/starfish',
    packages=find_packages(), py_modules=pyfiles)
