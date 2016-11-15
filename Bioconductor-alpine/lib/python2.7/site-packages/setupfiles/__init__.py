#!/usr/bin/env python
import distutils
from setupfiles.dist import DistributionMetadata
from setupfiles.setup import setup

__all__ = ["setup"]

distutils.dist.DistributionMetadata = DistributionMetadata
distutils.core.setup = setup
