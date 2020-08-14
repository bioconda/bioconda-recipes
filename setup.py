# -*- coding: UTF-8 -*-

from setuptools import setup, find_packages
import versioneer


setup(
    name='bioconda-utils',
    author="Johannes Köster, Ryan Dale, The Bioconda Team",
    description="Utilities for building and managing conda packages",
    license="MIT",
    packages=find_packages(exclude=['test']),
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
    entry_points={"console_scripts": [
        "bioconda-utils = bioconda_utils.cli:main"
    ]},
    classifiers=[
        "Development Status :: 4 - Beta",
        # "Development Status :: 5 - Production/Stable",
        "Environment :: Console",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Programming Language :: Python :: 3"
    ],
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
)
