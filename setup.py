# -*- coding: UTF-8 -*-

from setuptools import setup

# load version info
exec(open("bioconda_utils/version.py").read())

setup(
    name='bioconda-utils',
    version=__version__,
    author="Johannes Köster, Ryan Dale, The Bioconda Team",
    description="Utilities for building and managing conda packages",
    license="MIT",
    packages=["bioconda_utils"],
    include_package_data=True,
    data_files=[
        (
            'bioconda_utils',
            [
                'bioconda_utils/bioconda_utils-requirements.txt',
                'bioconda_utils/config.schema.yaml',
            ],
        )
    ],
    install_requires=["argh", "networkx", "pydotplus", "pyyaml", "requests", "jsonschema", "pandas", "colorlog", "jinja2"],
    entry_points={"console_scripts": [
        "bioconda-utils = bioconda_utils.cli:main",
        "bioconductor_skeleton = bioconda_utils.bioconductor_skeleton:main"
    ]},
    classifiers=[
        "Development Status :: 4 - Beta",
        #"Development Status :: 5 - Production/Stable",
        "Environment :: Console",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Programming Language :: Python :: 3"
    ]
)
