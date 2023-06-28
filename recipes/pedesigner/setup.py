from setuptools import setup

version = '0.2.0'

setup(
    name = 'pedesigner',
    version = version,
    packages = ['pedesigner'],
    description = 'A tool for prime-editing guideRNA (pegRNA) design',
    author = 'Vered Kunik',
    author_email = 'vered.kunik@gmail.com',
    url = 'https://github.com/VeredKunik/pedesigner',
    keywords = ['prime-editing','guideRNA','pegRNA','bioinformatics'],
    python_requires=">=3.7",
    license = 'GNU General Public License v3 (GPLv3)',
    classifiers=[  # Get strings from http://pypi.python.org/pypi?%3Aaction=list_classifiers
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 3',
        'Topic :: Scientific/Engineering :: Bio-Informatics'
    ],
    entry_points={
        'console_scripts': [
            'pedesigner = pedesigner.pedesigner:main'
        ]
    }
)
