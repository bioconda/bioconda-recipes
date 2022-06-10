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
CMD = ['conda', 'create', '-n', 'bioconda', '-y', '-c', 'conda-forge', '-c', 'bioconda', 'bioconda-utils={}'.format(common['BIOCONDA_UTILS_TAG'].strip('v'))]
if sys.platform != 'linux':
    CMD.append('conda-forge-ci-setup=3.20.0')

subprocess.check_call(CMD)
