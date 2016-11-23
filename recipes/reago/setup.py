try:
    from setuptools import setup
except ImportError:
    from distutils import setup

readme = open('README.md', 'r')
README_TEXT = readme.read()
readme.close()

setup(
    name='reago',
    version='1.1',
    description='An assemmly tool for 16S ribosomal RNA recovery from metagenomic data',
    long_description=README_TEXT,
    author='Cheng Yuan',
    author_email='chengyuan.china@gmail.com',
    url='https://github.com/chengyuan/reago-1.1',
    install_requires=['python-dateutil'],
    packages=['reago'],
    classifiers=[
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
        'Topic :: Software Development :: Libraries :: Python Modules'
    ]
)
