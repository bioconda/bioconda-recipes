#!/usr/bin/env python3

import argparse
import tarfile
import os
import urllib2
import shutil


METAPHLAN2_URL = 'https://bitbucket.org/biobakery/metaphlan2/get/2.5.0.tar.gz'


def download_file(url):
    """Download a file from a URL
    Fetches a file from the specified URL.
    Returns the name that the file is saved with.
    """
    print("Downloading %s" % url)
    target = os.path.basename(url)
    print("Saving to %s" % target)
    open(target, 'wb').write(urllib2.urlopen(url).read())
    return target


def unpack_tar_archive(tar_file):
    """Extract files from a TAR archive
    Given a TAR archive (which optionally can be
    compressed with either gzip or bz2), extract the
    files it contains and return a list of the
    resulting file names and paths.
    Once all the files are extracted the TAR archive
    file is deleted from the file system.
    """
    file_list = []
    if not tarfile.is_tarfile(tar_file):
        print("%s: not TAR file")
        return [tar_file]
    t = tarfile.open(tar_file)
    t.extractall(".")
    print("Removing %s" % tar_file)
    os.remove(tar_file)
    return file_list


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Download MetaPhlAn2 database')
    parser.add_argument('--output', help="Installation directory")
    args = parser.parse_args()

    if args.output:
        output = args.output
    else:
        output = os.path.dirname(os.path.realpath(__file__))
        print(output)
    if not os.path.exists(output):
        os.makedirs(output)

    metaphlan2_tarfile = download_file(METAPHLAN2_URL)
    file_list = unpack_tar_archive(metaphlan2_tarfile)
    print(file_list)

    shutil.move("biobakery-metaphlan2-c43e40a443ed/db_v20", output)
