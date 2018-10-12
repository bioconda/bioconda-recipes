#!/usr/bin/env python
#
# Wrapper script for Java Conda packages that ensures that the java runtime
# is invoked with the right options. 
# The script was taken from peptide-shaker and adapted for fseq.
# The peptide-shaker script was in turn adapted from the bash script 
# (http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128).
# When the program fseq is called with -h, it exits with 1. To make the installation testable,
# --test flag was added.

#
# Program Parameters
#
import io
import os
import subprocess
import sys
import shutil
from os import access
from os import getenv
from os import X_OK
jar_files = ['commons-cli-1.1.jar', 'fseq.jar']
main_path = 'edu.duke.igsp.gkde.Main'
default_jvm_mem_opts = ['-Xms512m', '-Xmx8g']

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
    usage_req = False
    is_test = False

    for arg in argv:
        if arg.startswith('-D'):
            prop_opts.append(arg)
        elif arg.startswith('-XX'):
            prop_opts.append(arg)
        elif arg.startswith('-Xm'):
            mem_opts.append(arg)
        elif arg == '--test':
            is_test = True
        else:
            pass_args.append(arg)
            if arg == '-h' or arg == '--help':
                usage_req = True

    # In the original shell script the test coded below read:
    #   if [ "$jvm_mem_opts" == "" ] && [ -z ${_JAVA_OPTIONS+x} ]
    # To reproduce the behaviour of the above shell code fragment
    # it is important to explictly check for equality with None
    # in the second condition, so a null envar value counts as True!

    if mem_opts == [] and getenv('_JAVA_OPTIONS') is None:
        mem_opts = default_jvm_mem_opts

    return (mem_opts, prop_opts, pass_args, is_test, usage_req)


def main():
    java = java_executable()
    (mem_opts, prop_opts, pass_args, is_test, usage_req) = jvm_opts(sys.argv[1:])
    jar_dir = os.path.join(real_dirname(sys.argv[0]), "..", "lib")

    jar_arg = '-cp'

    jar_path = ":".join([os.path.join(jar_dir, x) for x in jar_files])

    java_args = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + [main_path] + pass_args

    if not is_test:
        # Note that the preferred way as of v3.5 is subprocess.run
        exit_code = subprocess.call(java_args)
        if usage_req:
            print(
                '\n'
                'You can also specify JVM parameters such as -D, -XX, or -Xm.\n'
                'If you get an "OutOfMemory" error, simply increase the heap size by adding -Xmx '
                'parameter.\n'
                'E.g. fseq -Xmx12g input.bed'
            )
        sys.exit(exit_code)
    else:
        cmd = subprocess.Popen(java_args, stdout=subprocess.PIPE)
        cmd_out, cmd_err = cmd.communicate()
        if "usage: fseq [options]" in cmd_out.decode().lower():
             sys.exit(0)
        else:
             print(cmd_out.decode())
             sys.exit(1)



if __name__ == '__main__':
    main()
