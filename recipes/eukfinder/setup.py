from setuptools import setup

setup(
    name="eukfinder",
    version="1.2.3",
    py_modules=["Eukfinder"],
    entry_points={
        'console_scripts': [
            'eukfinder = Eukfinder:main',
        ],
    },
)