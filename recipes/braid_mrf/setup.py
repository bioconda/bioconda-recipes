#!/usr/bin/env python

from setuptools import find_packages, setup

setup(name='meanfield',
      version='1.0.1',
      description='A ',
      author='Wasinee Rungsarityotin',
      author_email='wasinees@gmail.com',
      url='https://github.com/wasineer-dev/braid',
      packages=find_packages(
        where='.',
        include=['meanfield*'],  # ["*"] by default
        exclude=[''],  # empty by default
      ),
     )