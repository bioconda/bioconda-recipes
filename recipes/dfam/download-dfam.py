#!/usr/bin/env python3

import argparse
import wget
import shutil

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Download dfam db')

    parser.add_argument('--output', help='Give an output destination /home/user/Dfam.hmm.gz')

    args = parser.parse_args()

    url = 'http://dfam.org/releases/Dfam_${PKG_VERSION}/families/Dfam.hmm.gz'

    if args.output:
        print("We are downloading file to {}".format(args.output))
        filename = wget.download(url)
        shutil(filename, args.output)
    else:
        print("We are downloading file to Dfam.hmm.gz")
        filename = wget.download(url)
