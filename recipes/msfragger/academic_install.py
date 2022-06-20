#!/usr/bin/env python3

import argparse
import re
import urllib.request
import urllib.parse

def download_url(url, post_dict, dest):
    if post_dict:
        data = urllib.parse.urlencode(post_dict).encode('ascii')
    else:
        data = None
    if dest:
        with open(dest, 'wb') as wh:
            size = 0
            with urllib.request.urlopen(url, data) as f:
                while True:
                    seg = f.read(1000000)
                    bytes_read = len(seg)
                    if bytes_read < 1:
                        break
                    size += bytes_read
                    wh.write(seg)
            return size
    else:
        with urllib.request.urlopen(url) as f:
            resp = f.read()
        return resp

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Install software licenced for acedemic use"
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
        '-m', '--msfragger_version', help='MSFragger version'
    )
    parser.add_argument(
        '-i', '--ionquant_version', help='IonQuant version'
    )
    parser.add_argument(
        '-p', '--path', default='.', help='path in which to install'
    )
    args = parser.parse_args()

    name = args.name
    email = args.email
    organization = args.organization

    def parse_version(version_string):
        version_pattern = '([\d.]+)'
        m = re.search(version_pattern, version_string.strip())
        if m:
            return m.groups()[0]
        return None

    if args.msfragger_version is not None:
        if args.msfragger_version == 'latest':
            url = 'http://msfragger-upgrader.nesvilab.org/upgrader/latest_version.php'
            latest = download_url(url, None, None)
            if latest:
                fgr_ver = parse_version(latest.decode('utf-8'))
        else:
            fgr_ver = parse_version(args.msfragger_version)
        if fgr_ver:
            fgr_zip = 'Release ' + fgr_ver + '$zip'
            print(fgr_zip)
            dest = args.path.rstrip('/') + '/MSFragger-' + fgr_ver + '.zip'
            url = 'http://msfragger-upgrader.nesvilab.org/upgrader/upgrade_download.php'
            data = {'transfer': 'academic', 'agreement1': 'true', 'agreement2': 'true','agreement3': 'true', 'name': name, 'email' : email, 'organization' : organization, 'download': fgr_zip}
            download_url(url, data, dest)
        else:
            print(f'Could not find version: {args.msfragger_version}')

    if args.ionquant_version is not None:
        if args.ionquant_version == 'latest':
            url = 'http://msfragger-upgrader.nesvilab.org/ionquant/latest_version.php'
            latest = download_url(url, None, None)
            if latest:
                iq_ver = parse_version(latest.decode('utf-8'))
        else:
             iq_ver = parse_version(args.ionquant_version)
        if iq_ver:
            iq_jar = iq_ver + '$jar'
            dest = args.path.rstrip('/') + '/IonQuant-' + iq_ver + '.jar'
            url = 'http://msfragger-upgrader.nesvilab.org/ionquant/upgrade_download.php'
            data = {'transfer': 'academic', 'agreement1': 'true', 'name': name, 'email' : email, 'organization' : organization, 'download': iq_jar}
            download_url(url, data, dest)
        else:
            print(f'Could not find version: {args.ionquant_version}')



