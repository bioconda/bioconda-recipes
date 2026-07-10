#!/usr/bin/env python
#
# Wrapper script for Java Conda packages that ensures that the java runtime
# is invoked with the right options. Adapted from the bash script (http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128).
#

import glob
import os
import sys
import subprocess

jar_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), "diaTracer.jar")

default_jvm_mem_opts = ['-Xms512m', '-Xmx1g']

license_agreement_text = '''
Please provide pass a license key with the --key argument. You may obtain a key by agreeing to the terms at msfragger-upgrader.nesvilab.org/diatracer/.
'''

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


def jvm_opts(argv):
    """Construct list of Java arguments based on our argument list.

    The argument list passed in argv must not include the script name.
    The return value is a 3-tuple lists of strings of the form:
      (memory_options, prop_options, passthrough_options)
    """
    mem_opts = []
    prop_opts = []
    pass_args = []

    for arg in argv:
        if arg.startswith('-D'):
            prop_opts.append(arg)
        elif arg.startswith('-XX'):
            prop_opts.append(arg)
        elif arg.startswith('-Xm'):
            mem_opts.append(arg)
        else:
            pass_args.append(arg)

    # In the original shell script the test coded below read:
    #   if [ "$jvm_mem_opts" == "" ] && [ -z ${_JAVA_OPTIONS+x} ]
    # To reproduce the behaviour of the above shell code fragment
    # it is important to explictly check for equality with None
    # in the second condition, so a null envar value counts as True!

    if mem_opts == [] and os.getenv('_JAVA_OPTIONS') == None:
        mem_opts = default_jvm_mem_opts

    return (mem_opts, prop_opts, pass_args)


def main():
    java = java_executable()
    jar_dir = real_dirname(sys.argv[0])
    jar_path = os.path.join(jar_dir, jar_file)
    jar_arg = '-jar'

    (mem_opts, prop_opts, pass_args) = jvm_opts(sys.argv[1:])

    if '--key' not in sys.argv:
        print(license_agreement_text)
        sys.exit(1)

    java_args = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + pass_args

    # Find Bruker libraries in MSFragger installation and add to path for diaTracer
    conda_prefix = os.getenv('CONDA_PREFIX')
    bruker_path = glob.glob('share/msfragger-*/MSFragger-*/ext/bruker', root_dir=conda_prefix)[0]
    ld_library_path = f'{conda_prefix}/{bruker_path}:{os.getenv("LD_LIBRARY_PATH","")}'

    sys.exit(subprocess.call(java_args, env={**os.environ, 'LD_LIBRARY_PATH': ld_library_path}))

if __name__ == '__main__':
    main()
