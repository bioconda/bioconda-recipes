#!/usr/bin/env python

from setuptools import find_packages, setup

setup(name='braid_mrf',
      version='1.0.1',
      description='A ',
      author='Wasinee Rungsarityotin',
      author_email='wasinees@gmail.com',
      url='https://github.com/wasineer-dev/braid',
      package_dir= {".": "meanfield"},
      packages=find_packages(
        where='.',
        include=['meanfield*'],  # ["*"] by default
        exclude=[''],  # empty by default
      ),
     )