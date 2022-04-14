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

jar_file = 'SearchGUI-4.0.41.jar'

default_jvm_mem_opts = ['-Xms2g', '-Xmx4g']

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
                src = real_dirname(sys.argv[0])
                os.remove(os.path.join(exec_dir, "resources/XTandem/linux/linux_64bit/tandem"))
                os.symlink(os.path.join(src, "resources/XTandem/linux/linux_64bit/tandem"),
                           os.path.join(exec_dir, "resources/XTandem/linux/linux_64bit/tandem"))

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

        if '-search_engine_temp' not in args and '-temp_folder' not in args :
            args.append('-temp_folder')
            args.append(TEMP)

    return args

def main():
    java = java_executable()
    """
    SearchGui updates files relative to the path of the jar file.
    In a multiuser setting, the option --exec_dir="exec_dir"
    can be used as the location for the peptide-shaker distribution.
    If the exec_dir dies not exist,
    we copy the jar file, lib, and resources to the exec_dir directory.
    """
    (mem_opts, prop_opts, pass_args, exec_dir) = jvm_opts(sys.argv[1:])

    pass_args = def_temp_log_opts(pass_args)

    jar_dir = exec_dir if exec_dir else real_dirname(sys.argv[0])

    if pass_args != [] and (pass_args[0].startswith('eu') or pass_args[0].startswith('com')):
        jar_arg = '-cp'
    else:
        jar_arg = '-jar'

    jar_path = os.path.join(jar_dir, jar_file)

    java_args = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + pass_args

    new_env = dict( os.environ )
    new_env['LC_ALL'] = 'C'

    sys.exit(subprocess.call(java_args, env=new_env))

if __name__ == '__main__':
    main()
