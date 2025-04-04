#!/usr/bin/env python3

# Automates accepting the academic license agreements in order to download MSFragger. A user of this package is then expected to accept the terms themselves when they download a license key from the MSFragger site, which is enforced by the wrapper script and MSFragger jar file.

import argparse
import hashlib
import os
import re
import sys
import urllib.request
import urllib.parse

MSFRAGGER_URL = 'http://msfragger-upgrader.nesvilab.org/upgrader/upgrade_download.php'
DOWNLOAD_READ_SIZE = 1000000

def download_url(url, post_dict, dest):
    data = urllib.parse.urlencode(post_dict).encode('ascii')
    with open(dest, 'wb') as wh:
        size = 0
        m = hashlib.sha256()
        with urllib.request.urlopen(url, data) as f:
            while True:
                seg = f.read(DOWNLOAD_READ_SIZE)
                m.update(seg)
                bytes_read = len(seg)
                if bytes_read < 1:
                    break
                size += bytes_read
                wh.write(seg)

        return m.hexdigest()

def parse_version(version_string):
    version_pattern = '([\\d.]+)'
    m = re.search(version_pattern, version_string.strip())
    if m:
        return m.groups()[0]
    return None

parser = argparse.ArgumentParser(
    description="Download MSFragger zip file."
)
parser.add_argument(
    '-n', '--name', help='user name'
)
parser.add_argument(
    '-e', '--email', help='email'
)
parser.add_argument(
    '-o', '--organization', help='institutional organization'
)
parser.add_argument(
    '-m', '--msfragger_version', help='MSFragger version', required=True
)
parser.add_argument(
    '-p', '--path', default='.', help='path in which to install'
)
parser.add_argument(
    '--hash', default='.', help='SHA256 hash of downloaded zip'
)

args = parser.parse_args()
fgr_ver = parse_version(args.msfragger_version)
if fgr_ver is None:
    print(f'Could not find version: {args.msfragger_version}', file=sys.stderr)
    sys.exit(1)

fgr_zip = 'Release ' + fgr_ver + '$zip'
dest = os.path.join(args.path, 'MSFragger-' + fgr_ver + '.zip')
data = {'transfer': 'academic', 'agreement1': 'true', 'agreement2': 'true','agreement3': 'true', 'name': args.name, 'email' : args.email, 'organization' : args.organization, 'download': fgr_zip}

if download_url(MSFRAGGER_URL, data, dest) != args.hash:
    print('Invalid hash calculated.', file=sys.stderr)
    sys.exit(1)
