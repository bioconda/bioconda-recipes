#!/usr/bin/env python3
from setuptools import setup
from setuptools.command.install import install
import os
import sys

__version__ = '0.1.9'

def readme():
    with open('README.md') as f:
        return f.read()

def check_dir_write_permission(directory):
    if os.path.isdir(directory) and not os.access(directory, os.W_OK):
        sys.exit('Error: no write permission for ' + directory + '  ' +
                 'Perhaps you need to use sudo?')

class HandyReadGenotyperInstall(install):

    def run(self):
        check_dir_write_permission(self.install_lib)
        install.run(self)



setup(name='HandyReadGenotyper',
      version=__version__,
      description='HandyReadGenotyper',
      long_description=readme(),
      python_requires='>=3.8,<3.9.0a0',
      classifiers=['Development Status :: Beta',
                   'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
                   'Programming Language :: Python :: 3',
                   'Topic :: Scientific/Engineering :: Bio-Informatics',
                   'Intended Audience :: Science/Research'],
      keywords='PCR amplicon primers',
      url='https://github.com/AntonS-bio/HandyReadGenotyper.git',
      author='Anton Spadar',
      author_email='',
      packages=['scripts'],
      include_package_data=True,
      entry_points={'console_scripts': ['classify = classify:main', 'train = train:main']},
      scripts=[
          'scripts/classify.py',
          'scripts/data_classes.py',
          'scripts/genotyper_data_classes.py',
          'scripts/input_processing.py',
          'scripts/inputs_validation.py',
          'scripts/model_manager.py',
          'scripts/read_classifier.py',
          'scripts/train.py'
      ],
      cmdclass={'install': HandyReadGenotyperInstall}
)
