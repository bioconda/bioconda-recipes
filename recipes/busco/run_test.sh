#!/bin/bash

# The directory in which generate-busco-config.py is stored should itself be
# found in the "path = " lines of its output
d=$(dirname $(which generate-busco-config.py))
generate-busco-config.py | grep "path = " | grep $d
