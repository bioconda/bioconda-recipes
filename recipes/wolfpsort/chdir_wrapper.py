#!/usr/bin/env python
#Wrapper script to call WoLF PSORT from its own directory.
import os
import sys
import subprocess
saved_dir = os.path.abspath(os.curdir)

# This wrapper will be in ${PREFIX}/bin/
# and we want to chage to ${PREFIX}/opt/bin/

tool_name = os.path.basename(sys.argv[0])
tool_path = os.path.join(os.path.dirname(os.path.realpath(sys.argv[0])), "../opt/bin")
if not os.path.isdir(tool_path):
    sys.exit("Could not find wrapped tool directory: %s" % tool_path)
if not os.path.isfile(os.path.join(tool_path, tool_name)):
    sys.exit("Could not find wrapped tool at path: %s" % os.path.join(tool_path, tool_name))

os.chdir(tool_path)
if not os.path.isfile(tool_name):
    os.chdir(saved_dir)
    sys.exit("Could not find wrapped tool %s in %s" % (tool_name, tool_path))
if not os.access("./" + tool_name, os.X_OK):
    os.chdir(saved_dir)
    sys.exit("Wrapped tool %s in %s not executable" % (tool_name, tool_path))
args = ["./" + tool_name] + sys.argv[1:]
return_code = subprocess.call(args)
os.chdir(saved_dir)
sys.exit(return_code)
