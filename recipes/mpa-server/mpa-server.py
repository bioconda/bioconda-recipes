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

jar_file = 'MPA-3.3.jar'

default_jvm_mem_opts = ['-Xms512m', '-Xmx1g']

# !!! End of parameter section. No user-serviceable code below this line !!!


def printerr(*args, **kwargs):
    print(*args, **kwargs, file=sys.stderr)


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


def read_config(config_file):
    cfg = {}
    with open(config_file, "r") as f:
        for l in f.readlines():
            l_stripped = l.strip()
            if l_stripped.startswith("#"):
                continue
            elif l_stripped == "":
                continue
            else:
                split_vals = l_stripped.split("=")
                if len(split_vals) != 2:
                    printerr(f"Got unexpected line in config file '{config_file}'")
                    printerr(l)
                    sys.exit(1)
                cfg[split_vals[0]] = split_vals[1]
    return cfg


def set_cfg_values(dict_of_vals_to_change, config_file):
    out_lines = []
    with open(config_file, "r") as f:
        for l in f.readlines():
            l_stripped = l.strip()
            if l_stripped.startswith("#"):
                pass
            elif l_stripped == "":
                pass
            else:
                split_vals = l_stripped.split("=")
                if len(split_vals) != 2:
                    printerr(f"Got unexpected line in config file '{config_file}'")
                    printerr(l)
                    sys.exit(1)
                else:
                    key, value = split_vals
                    if key in dict_of_vals_to_change:
                        l = l.replace(value, str(dict_of_vals_to_change[key]))
                        del dict_of_vals_to_change[key]
            out_lines.append(l)
    if dict_of_vals_to_change:
        if not l.endswith("\n"):
            out_lines.append("\n")
        out_lines.extend([f"{k}={v}\n" for k, v in dict_of_vals_to_change.items()])
    with open(config_file, "w") as f:
        f.writelines(out_lines)


def is_first_run(config):
    if ("first_run" not in config) or (config["first_run"] == "True"):
        return True
    return False


class SqlServerWrapper:
    def __init__(self, datadir):
        self.datadir = datadir

    def __enter__(self):
        args = ["mysqld", "--datadir", self.datadir]
        printerr("Starting MySQL-Server: '", " ".join(args), "'", sep='')
        self.daemon = subprocess.Popen(args)

    def __exit__(self, type, value, traceback):
        # send term signal to mysqld
        printerr("Shutting down MySQL-Server... ", end='')
        self.daemon.terminate()
        self.daemon.communicate()
        printerr("Done!")


def main():
    java = java_executable()
    """
    PeptideShaker updates files relative to the path of the jar file.
    In a multiuser setting, the option --exec_dir="exec_dir"
    can be used as the location for the peptide-shaker distribution.
    If the exec_dir dies not exist,
    we copy the jar file, lib, and resources to the exec_dir directory.
    """
    (mem_opts, prop_opts, pass_args, exec_dir) = jvm_opts(sys.argv[1:])
    jar_dir = exec_dir if exec_dir else real_dirname(sys.argv[0])

    if pass_args != [] and pass_args[0].startswith('eu'):
        jar_arg = '-cp'
    else:
        jar_arg = '-jar'

    jar_path = os.path.join(jar_dir, jar_file)

    java_args = [java] + mem_opts + prop_opts + [jar_arg] + [jar_path] + pass_args

    config_file = os.path.join(jar_dir, "config_LINUX.properties")
    cfg = read_config(config_file)
    if is_first_run(cfg):
        while True:
            user_input = input("Download preprocessed FASTA Database (~1.2Gb)? [Y/n]").lower()
            if user_input not in ["", "y", "n"]:
                print("Valid options are: y, n")
            else:
                if user_input in ["", "y"]:
                    wants_db = True
                else:
                    wants_db = False
                break
        if wants_db:
            printerr("dummydownload")
            # download_db_dump()
            # load_db_dump()
        set_cfg_values({"first_run": False}, config_file)

    with SqlServerWrapper(cfg["sqlDataDir"]):
        java_exit_code = subprocess.call(java_args)

    sys.exit(java_exit_code)


if __name__ == '__main__':
    main()
