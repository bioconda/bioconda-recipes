from setuptools import setup, find_packages
import os

# Get list of shell scripts
shell_scripts = [os.path.join('muat/pkg_shell', f) for f in os.listdir('muat/pkg_shell') 
                if f.endswith('.sh')]

setup(
    name="muat",
    version="0.1.0",
    packages=find_packages(),
    package_data={
        'muat': [
            'pkg_data/*',
            'pkg_shell/*.sh',  # Make sure shell scripts are included as package data
        ],
    },
    scripts=shell_scripts,  # Install as executable scripts
    install_requires=[
        "numpy",
        "pandas",
        "requests",
    ],
    entry_points={
        "console_scripts": [
            "muat=muat.core:main",  # Change this to your actual CLI entry point
        ]
    },
    include_package_data=True,  # Important for conda packaging
)
