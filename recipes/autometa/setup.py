"""Setup for installation of Autometa."""


import os

from setuptools import setup
from setuptools import find_packages

def read(fname):
    """Read a file from the current directory."""
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

long_description = read('README.md')
version = read('VERSION').strip()

setup(
    name='Autometa',
    python_requires='>=3.7',
    version=version,
    packages=find_packages(exclude=["tests"]),
    package_data={'':['*.config']},
    entry_points={
        'console_scripts':[
            'autometa = autometa.__main__:entrypoint',
            'autometa-configure = autometa.config.user:main',
            'autometa-kmers = autometa.common.kmers:main',
            'autometa-coverage = autometa.common.coverage:main',
            'autometa-markers = autometa.common.markers:main',
        ]
    },
    author='Jason C. Kwan',
    author_email='jason.kwan@wisc.edu',
    description='Automated Extraction of Genomes from Shotgun Metagenomes',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/KwanLab/Autometa',
    license='GNU Affero General Public License v3 or later (AGPLv3+)',
    classifiers=[
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.7',
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Science/Research',
        'Topic :: Scientific/Engineering :: Bio-Informatics',
        'License :: OSI Approved :: GNU Affero General Public License v3 or later (AGPLv3+)',
        'Operating System :: OS Independent',
    ],
)
