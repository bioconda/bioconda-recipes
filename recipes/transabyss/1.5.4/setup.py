import subprocess
from setuptools import setup, find_packages, Extension

setup(
    name='transabyss',
    version='1.5.4',
    author='transabyss',
    license='Free Software License',
    packages=['transabyss'],
    scripts=['scripts/transabyss', 'scripts/transabyss-merge'],
)
