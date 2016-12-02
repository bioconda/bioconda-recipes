from setuptools import setup

setup(
    name='reago',
    version='1.1',
    description='An assemmly tool for 16S ribosomal RNA recovery from metagenomic data',
    author='Cheng Yuan',
    author_email='chengyuan.china@gmail.com',
    url='https://github.com/chengyuan/reago-1.1',
    install_requires=['networkx'],
    scripts = ['reago.py'],
    classifiers=[
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3'
    ]
)
