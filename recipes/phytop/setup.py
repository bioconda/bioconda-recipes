#!/usr/bin/env python
from src.__version__ import version

from setuptools import setup, find_packages
from distutils.extension import Extension
#from Cython.Build import cythonize

with open('README.md') as f:
    long_description = f.read()


setup(
    name='PhyTop',
    version=version,
    description='PhyTop: visualing species tree from ASTRAL',
    url='https://github.com/zhangrengang/phytop/',
    author='Zhang, Ren-Gang and Wang, Zhao-Xuan',
    license='GPL-3.0',

    python_requires='>=3.6',
    packages=find_packages(),
    include_package_data=True,
    scripts=[],
    entry_points={
        'console_scripts': ['phytop = src.plot:main',
        ],
    },
)
