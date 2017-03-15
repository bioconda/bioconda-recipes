#!/bin/bash

# Click tests for python3 unicode handling using the `locale`
# executable, which does not seem to be present in busybox.
# The workaround is to bypass the `locale` test by setting the
# LANG env variable directly (from looking at Click's source).
LANG=en_US.UTF-8 fsnviz --help
