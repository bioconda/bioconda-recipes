#!/bin/sh
env MAX_READLENGTH=500 ./configure --prefix=$PREFIX
make
make install prefix=$PREFIX

# Citation from the README:
#
# Note 3: GSNAP previously had a configure variable called
# MAX_READLENGTH (default 300) as a guide to the maximum read length.
# That variable is no longer needed, since GSNAP can align reads of
# arbitrary length.  (But, for longer reads, GMAP will probably be much
# faster.)
#
# However, whenever possible, based on the length of the read, GSNAP
# will use stack memory instead of heap memory for some algorithms.  To
# control this decision, there is a variable called
# MAX_STACK_READLENGTH, set like this
#
#    ./configure MAX_STACK_READLENGTH=<length>
