#!/usr/bin/env python

import os
import subprocess
import sys
from os import access, getenv, path, X_OK


# jar file
JAR_NAME = 'gametes.jar'
PKG_NAME = 'gametes'
PKG_VERSION = '2.1'
PKG_BUILDNUM = '0'


default_jvm_mem_opts = ['-Xms512m', '-Xmx1g']

#def real_dirname(in_path):
    #"""Return the path to the JAR file"""
    #realPath = os.path.dirname(os.path.realpath(in_path))
    #newPath = os.path.realpath(os.path.join(realPath, "..", "share", PKG_NAME))
    #return newPath
    #"""Return the symlink-resolved, canonicalized directory-portion of path."""
    #return os.path.dirname(os.path.realpath(path))



def real_dirname(in_path):
    """Return the path to the JAR file"""
    #realPath = os.path.dirname(os.path.realpath(in_path))
    realPath = os.path.dirname(os.path.dirname(os.path.realpath(in_path)))
    newPath = os.path.realpath(os.path.join(realPath, "..", "share", "{}-{}-{}".format(PKG_NAME, PKG_VERSION, PKG_BUILDNUM)))
    return newPath


#def java_executable():
#    """Return the executable name of the Java interpreter."""
#    java_home = getenv('JAVA_HOME')
#    java_bin = os.path.join('bin', 'java')
#    env_prefix = os.path.dirname(os.path.dirname(real_dirname(sys.argv[0])))

#    if java_home and access(os.path.join(java_home, java_bin), X_OK):
#        return os.path.join(java_home, java_bin)
#    else:
#        # Use Java installed with Anaconda to ensure correct version
#        return os.path.join(env_prefix, 'bin', 'java')

#def java_executable():
#    """Return the executable name of the Java interpreter."""
#    java_home = getenv('JAVA_HOME')
#    java_bin = os.path.join('bin', 'java')
#    env_bin = os.path.join(sys.prefix, 'bin', 'java')  # Path to java in Conda env

#    if java_home and access(os.path.join(java_home, java_bin), X_OK):
#        return os.path.join(java_home, java_bin)
#    elif access(env_bin, X_OK):
#        return env_bin
#    else:
#        raise FileNotFoundError("Java executable not found in JAVA_HOME or Conda environment.")

#def java_executable():
#    """Returns the name of the Java executable."""
#    java_home = getenv('JAVA_HOME')
#    java_bin = path.join('bin', 'java')
#    env_prefix = os.path.dirname(os.path.dirname(real_dirname(sys.argv[0])))

#    if java_home and access(os.path.join(java_home, java_bin), X_OK):
#        return os.path.join(java_home, java_bin)
#    else:
#        # Use Java installed with Anaconda to ensure correct version
#        return os.path.join(env_prefix, 'bin', 'java')

def java_executable():
    """Returns the name of the Java executable."""
    java_home = getenv('JAVA_HOME')
    java_bin = path.join('bin', 'java')
    if java_home and access(os.path.join(java_home, java_bin), X_OK):
        return os.path.join(java_home, java_bin)
    else:
        return "java"  # Default to using 'java' command directly
        


def jvm_opts(argv):
    """Construct list of Java arguments based on our argument list.

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
        mem_opts = default_jvm_mem_opts

    return (mem_opts, prop_opts, pass_args)

def main():
    java = java_executable()
    jar_dir = real_dirname(sys.argv[0])
    (mem_opts, prop_opts, pass_args) = jvm_opts(sys.argv[1:])

    if pass_args != [] and pass_args[0].startswith('org'):
        jar_arg = '-cp'
    else:
        jar_arg = '-jar'

    jar_path = os.path.join(jar_dir, JAR_NAME)

    if not os.path.isfile(jar_path):
        sys.stderr.write('GAMETES jar file not found\n')
        sys.exit(1)

    java_args = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + pass_args
    sys.exit(subprocess.call(java_args))


if __name__ == '__main__':
    main()


