from distutils.core import setup
import os

setup(name='Omero Python',
    version=os.environ['OMERO_VERSION'],
    description='OME (Open Microscopy Environment) develops open-source software and data format standards for the storage and manipulation of biological light microscopy data.',
    url='http://www.openmicroscopy.org/',
    packages=['omero', 'omeroweb', 'pipeline', 'omero_ext']
)