#!/usr/bin/env python
import subprocess
import os
import sys

def parseCommonSH():
    """Parse common.sh in the current working directory, returning a dictionary
       version of its key=value pairs"""
    d = {}
    for line in open('common.sh'):
        cols = line.strip().split('=')
        if len(cols) == 2:
            d[cols[0]] = cols[1]
    return d


if not os.path.exists('common.sh'):
    sys.exit("Can't find common.sh!")

common = parseCommonSH()
if sys.platform == 'linux':
    CMD = ['conda', 'create', '-n', 'bioconda', '-y', 'bioconda-utils={}'.format(common['BIOCONDA_UTILS_TAG'])]
else:
    CMD = ['conda', 'create', '-n', 'bioconda', '-y', 'bioconda-utils={}'.format(common['BIOCONDA_UTILS_TAG']), 'conda-forge-ci-setup=2.6.0']

subprocess.check_call(CMD)
