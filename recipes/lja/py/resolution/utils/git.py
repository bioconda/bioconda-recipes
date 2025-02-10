# (c) 2020 by Authors
# This file is a part of centroFlye program.
# Released under the BSD license (see LICENSE file)

import subprocess

def get_git_revision_hash():
    return subprocess.run(['git', 'rev-parse', 'HEAD'], check=False, stderr=open("/dev/null"), stdout=subprocess.PIPE).stdout.decode('ascii').strip()

def get_git_revision_short_hash():
    return subprocess.run(['git', 'rev-parse', '--short', 'HEAD'], check=False, stderr=open("/dev/null"), stdout=subprocess.PIPE).stdout.decode('ascii').strip()
