#!/usr/bin/python

from setuptools import setup, find_packages
from os import listdir

pyfiles = [f.replace('.py', '') for f in listdir('.') if f.endswith('.py')]
setup(name='PyMOT', version='13.09.2016', description='The Multiple Object Tracking (MOT) metrics "multiple object tracking precision" (MOTP) and "multiple object tracking accuracy" (MOTA) allow for objective comparison of tracker characteristics [0]. The MOTP shows the ability of the tracker to estimate precise object positions, independent of its skill at recognizing object configurations, keeping consistent trajectories, and so forth. The MOTA accounts for all object configuration errors made by the tracker, false positives, misses, mismatches, over all frames.', url='https://github.com/Videmo/pymot', packages=find_packages(), py_modules=pyfiles)
