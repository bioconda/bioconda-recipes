#!/usr/bin/env python
#
# Wrapper script for Java Conda packages that ensures that the java runtime is invoked with the right options.
# Adapted from https://github.com/bioconda/bioconda-recipes/blob/master/recipes/peptide-shaker/peptide-shaker.py

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

jar_file = 'webin-cli-3.7.0.jar'
default_jvm_mem_opts = ['-Xms2g', '-Xmx4g']
original_string = "java -jar " + jar_file + " CLI"
wrapper_string = "webin-cli"

# !!! End of parameter section. No user-serviceable code below this line !!!


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
    """Construct list of Java arguments based on our argument list.

    The argument list passed in argv must not include the script name.
    The return value is a 3-tuple lists of strings of the form:
      (memory_options, prop_options, passthrough_options)
    """
    mem_opts = []
    prop_opts = []
    pass_args = []
    exec_dir = None

    for arg in argv:
        if arg.startswith('-D'):
            prop_opts.append(arg)
        elif arg.startswith('-XX'):
            prop_opts.append(arg)
        elif arg.startswith('-Xm'):
            mem_opts.append(arg)
        elif arg.startswith('--exec_dir='):
            exec_dir = arg.split('=')[1].strip('"').strip("'")
            if not os.path.exists(exec_dir):
                shutil.copytree(real_dirname(sys.argv[0]), exec_dir, symlinks=False, ignore=None)
        else:
            pass_args.append(arg)

    # In the original shell script the test coded below read:
    #   if [ "$jvm_mem_opts" == "" ] && [ -z ${_JAVA_OPTIONS+x} ]
    # To reproduce the behaviour of the above shell code fragment
    # it is important to explictly check for equality with None
    # in the second condition, so a null envar value counts as True!

    if mem_opts == [] and getenv('_JAVA_OPTIONS') is None:
        mem_opts = default_jvm_mem_opts

    return (mem_opts, prop_opts, pass_args, exec_dir)


def def_temp_log_opts(args):
    """
    Establish default temporary and log folders.
    """
    TEMP  = os.getenv("TEMP")

    if TEMP is not None:
        if '-log' not in args:
            args.append('-log')
            args.append(TEMP+'/logs')

        if '-temp_folder' not in args :
            args.append('-temp_folder')
            args.append(TEMP)

    return args

def main():
    java = java_executable()
    (mem_opts, prop_opts, pass_args, exec_dir) = jvm_opts(sys.argv[1:])
    pass_args = def_temp_log_opts(pass_args)
    jar_dir = exec_dir if exec_dir else real_dirname(sys.argv[0])
    jar_arg = '-jar'
    jar_path = os.path.join(jar_dir, jar_file)
    java_args = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + pass_args
    # cmd = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + [cli] + pass_args
    sys.exit(subprocess.call(java_args))

    # p = subprocess.Popen(cmd,stderr=subprocess.PIPE);
    # for line in iter(p.stderr.readline,b''):
        # tomod = line.decode("utf-8")
        # tomod = tomod.replace(original_string,wrapper_string)
        # print(tomod,end='')


if __name__ == '__main__':
    main()
