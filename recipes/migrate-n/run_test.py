#!/usr/bin/python

import os
import sys

if os.system('migrate-n -h') != 65280:
    sys.exit(-1)


#migrate-n has strange exit codes
