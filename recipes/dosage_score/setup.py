#! /usr/bin/env python3

from setuptools import setup, find_packages
from dosage_score.__init__ import __version__

setup(
    name="dosage_score",
    version='{}'.format(__version__),
    description='Dosage-score: pipline to estimate dosage of each genomic region',
    url='https://github.com/SegawaTenta/Dosage-score',
    author='Tenta Segawa',
    packages=['dosage_score'],
    entry_points={
        'console_scripts': [
            'dosage_score=dosage_score.dosage_score:main',
            'dosage_score_plot=dosage_score.dosage_score_plot:main'
        ]
    }
)
