#!/usr/bin/env python
import glob
import os
import sys
import argparse

if sys.argv[1].lower() in ['-h', '--help', 'help']:
    print('usage: %s > path-to-new-config-file.ini' % sys.argv[0])

# directory where symlink lives
bindir = os.path.dirname(os.path.abspath(__file__))

# directory after resolving symlink (which is where the example config file is
# found)
share = os.path.dirname(os.path.realpath(__file__))
config = os.path.join(share, 'config.ini.default')

# One option for editing paths would be to use configparser, but this would
# remove all the helpful comments in the config file. Instead, we match on "^path = "
lines = []
for line in open(config):
    if line.startswith('path = '):
        lines.append('path = ' + bindir + '\n')
    else:
        lines.append(line)
sys.stdout.write(''.join(lines))
