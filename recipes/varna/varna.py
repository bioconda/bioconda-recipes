#!/usr/bin/env python

# Wrapper script for the VARNA applet. Based on the peptide-shaker.py wrapper example on Bioconda.

# Arguments:
# varna [-i inputFile|-sequenceDBN XXX -structureDBN YYY] -o outFile [opts]

# See http://varna.lri.fr/index.php?lang=en&page=command&css=varna for more information

import subprocess
import os
import sys

jar_file = 'VARNAv3-93.jar'
default_jvm_mem_opts = ['-Xms512m', '-Xmx1g']


def real_dirname(path):
    """Return the symlink-resolved, canonicalized directory-portion of path."""
    return os.path.dirname(os.path.realpath(path))

def java_executable():
    """Return the executable name of the Java interpreter."""
    java_home = os.getenv('JAVA_HOME')
    java_bin = os.path.join('bin', 'java')

    if java_home and os.access(os.path.join(java_home, java_bin), os.X_OK):
        return os.path.join(java_home, java_bin)
    else:
        return 'java'


def main():
	java = java_executable()

	jar_path = real_dirname(sys.argv[0])

	java_args = [java] + default_jvm_mem_opts + ['-cp', os.path.join(jar_path, 'VARNAv3-93.jar'), 'fr.orsay.lri.varna.applications.VARNAcmd']


	if '-o' not in java_args:
		print('An output file (specified with) -o is required.')
		print('Usage: varna [-i inputFile|-sequenceDBN XXX -structureDBN YYY] -o outFile [opts]')
	else:
	
		sys.exit(subprocess.call(java_args + sys.argv[1:]))


if __name__ == '__main__':
    main()
