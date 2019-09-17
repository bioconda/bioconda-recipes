#!/usr/bin/env python
#
# Wrapper script for invoking the jar.
#
# This script is written for use with the Conda package manager and is ported
# from a bash script that does the same thing, adapting the style in
# the peptide-shaker wrapper
# (https://github.com/bioconda/bioconda-recipes/blob/master/recipes/peptide-shaker/peptide-shaker.py)

import subprocess
import sys
import os
from os import access, getenv, path, X_OK


# Expected name of the VarScan JAR file.
JAR_NAME = 'womtool.jar'
PKG_NAME = 'womtool'

# Default options passed to the `java` executable.
DEFAULT_JVM_MEM_OPTS = ['-Xms512m', '-Xmx1g']


def real_dirname(in_path):
    """Returns the path to the JAR file"""
    realPath = os.path.dirname(os.path.realpath(in_path))
    newPath = os.path.realpath(os.path.join(realPath, "..", PKG_NAME))
    return newPath


def java_executable():
    """Returns the name of the Java executable."""
    java_home = getenv('JAVA_HOME')
    java_bin = path.join('bin', 'java')
    env_prefix = os.path.dirname(os.path.dirname(real_dirname(sys.argv[0])))

    if java_home and access(os.path.join(java_home, java_bin), X_OK):
        return os.path.join(java_home, java_bin)
    else:
        # Use Java installed with Anaconda to ensure correct version
        return os.path.join(env_prefix, 'bin', 'java')

def jvm_opts(argv, default_mem_opts=DEFAULT_JVM_MEM_OPTS):
    """Constructs a list of Java arguments based on our argument list.


    The argument list passed in argv must not include the script name.
    The return value is a 3-tuple lists of strings of the form:
        (memory_options, prop_options, passthrough_options)

    """
    mem_opts, prop_opts, pass_args = [], [], []

    for arg in argv:
        if arg.startswith('-D') or arg.startswith('-XX'):
            opts_list = prop_opts
        elif arg.startswith('-Xm'):
            opts_list = mem_opts
        else:
            opts_list = pass_args
        opts_list.append(arg)

    if mem_opts == [] and getenv('_JAVA_OPTIONS') is None:
        mem_opts = default_mem_opts

    return (mem_opts, prop_opts, pass_args)


def main():
    java = java_executable()
    jar_dir = real_dirname(sys.argv[0])
    (mem_opts, prop_opts, pass_args) = jvm_opts(sys.argv[1:])

    if pass_args != [] and pass_args[0].startswith('org'):
        jar_arg = '-cp'
    else:
        jar_arg = '-jar'

    jar_path = path.join(jar_dir, JAR_NAME)
    java_args = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + pass_args
    sys.exit(subprocess.call(java_args))


if __name__ == "__main__":
    main()
