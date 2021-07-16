import os

from setuptools import setup, find_packages

base_dir = os.path.dirname(__file__)

description = "A tool for locking down your conda package usage."

setup(
    name='probeit',
    version='v1.0',
    author='Martin Steinegger',
    author_email='themartinsteinegger@gmail.com',
    license='GPLv3',
    description='probeit, probe designer for pathogen detector or genopyper',
    long_description='probeit, probe designer for pathogen detector or genopyper',
    url='https://github.com/steineggerlab/probeit'
    packages=find_packages(exclude=['tests']),
    include_package_data=True,
)
