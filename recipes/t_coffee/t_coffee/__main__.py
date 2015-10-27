import os
import sys
import subprocess

from . import config

def main():
    """Run the ``t_coffee`` multiple sequence alignment tool.

    Parameters
    ----------
    argv : list, optional
        A list of arguments to pass on to ``t_coffee``.
    """
    print("\n" + "*" * 80)
    print('Command line arguments: {0}'.format(sys.argv))
    print("Install folder: {0}".format(config.tcoffee_install_path))
    print("*" * 80 + "\n")
    env = config.get_tcoffee_environ()
    child_process = subprocess.Popen([config.tcoffee_exe_file] + sys.argv[1:], env=env)
    result, error_message = child_process.communicate()
    print("\n" + "*" * 80 )
    print("Result: {0}".format(result))
    print("Error message: {0}".format(error_message))
    print("*" * 80 + "\n")


if __name__ == '__main__':
    main()
