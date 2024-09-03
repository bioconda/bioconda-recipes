from setuptools import setup

setup(
    name="eukfinder",
    version="1.2.3",
    py_modules=["eukfinder"],
    entry_points={
        'console_scripts': [
            'eukfinder = eukfinder:main',
        ],
    },
)