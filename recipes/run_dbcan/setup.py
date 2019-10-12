#!/usr/bin/env python
#
# distutils setup script for dbcan package
# also installs the bundled Hotpep scripts and data files

from glob import glob
from os import listdir
from os.path import isfile
from setuptools import setup, find_packages

long_description = """This is the standalone version of dbCAN annotation tool for automated CAZyme annotation (known as run_dbCAN.py), written by Tanner Yohe and Le Huang. User manul please refer [run_dbcan](https://github.com/linnabrown/run_dbcan/blob/master/README.md)
"""

setup(name='run_dbcan',
      version="2.0.0",
    #   use_scm_version=True,
      setup_requires=['setuptools_scm', 'setuptools_scm_git_archive'],
      description='Standalone version of dbCAN annotation tool for automated CAZyme annotation',
      long_description=long_description,
      author='Tanner Yohe and Le Huang',
      author_email='lehuang@med.unc.edu',
      url='https://github.com/linnabrown/run_dbcan',
      classifiers=[
          'Development Status :: 4 - Beta',
          'Environment :: Console',
          'Intended Audience :: Science/Research',
          'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
          'Operating System :: POSIX :: Linux',
          'Programming Language :: Python :: 3',
          'Topic :: Scientific/Engineering :: Bio-Informatics',
      ],
      packages=find_packages(),
      include_package_data = True,
      package_data={
          'Hotpep': ['*.txt'],
      },

      scripts=[
          'CGCFinder.py',
          'hmmscan-parser.py',
          'run_dbcan.py',
          'dbcan_data_install.sh',
          'Hotpep/add_functions_orf.py',
          'Hotpep/bact_group_many_proteins_many_patterns.py',
          'Hotpep/list_multidomain_proteins.py',
          'Hotpep/parallel_group_many_proteins_many_patterns_noDNA.py',
          'Hotpep/train_many_organisms_many_families.py',
      ],
      license='GPLv3',
      install_requires=[
          'natsort',
          'setuptools'

      ],
      python_requires='>=3',
     )
