#!/usr/bin/env python
#
# Wrapper script for Java Conda packages that ensures that the java runtime
# is invoked with the right options. Adapted from the bash script (http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128).

#
# Program Parameters
#
import os
import subprocess
import sys
import shutil
from os import access
from os import getenv
from os import X_OK
jar_file = 'NP-Likeness-2.1.jar'

default_jvm_pass_args = ['-help']


def real_dirname(path):
    """Return the symlink-resolved, canonicalized directory-portion of path."""
    return os.path.dirname(os.path.realpath(path))


def java_executable():
    """Return the executable name of the Java interpreter."""
    java_home = getenv('JAVA_HOME')
    java_bin = os.path.join('bin', 'java')

    if java_home and access(os.path.join(java_home, java_bin), X_OK):
        return os.path.join(java_home, java_bin)
    else:
        return 'java'


def jvm_opts(argv):
    """
    Construct list of Java arguments based on our argument list.
    """
    pass_args = []

    for arg in argv:
        pass_args.append(arg)

    if pass_args == []:
        pass_args = default_jvm_pass_args

    return pass_args


def main():
    java = java_executable()
    """
    Calling of the tool ensuring that the java runtime is invoked with the right options.
    """
    pass_args = jvm_opts(sys.argv[1:])
    jar_dir = real_dirname(sys.argv[0])

    jar_arg = '-jar'

    jar_path = os.path.join(jar_dir, jar_file)

    java_args = [java] + [jar_arg] + [jar_path] + pass_args

    sys.exit(subprocess.call(java_args))


if __name__ == '__main__':
    main()
