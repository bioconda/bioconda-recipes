#!/usr/bin/env python
#Wrapper script to call WoLF PSORT from its own directory.
import os
import sys
import subprocess
saved_dir = os.path.abspath(os.curdir)
# This wrapper will be in ${PREFIX}/bin/
# and we want to chage to ${PREFIX}/opt/bin/
os.chdir(os.path.join(os.path.dirname(os.path.realpath(sys.argv[0])), "../opt/bin"))
args = ["./runWolfPsortSummary"] + sys.argv[1:]
return_code = subprocess.call(args)
os.chdir(saved_dir)
sys.exit(return_code)
