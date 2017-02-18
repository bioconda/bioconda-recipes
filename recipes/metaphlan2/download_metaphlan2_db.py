#!/usr/bin/env python3

import argparse
import tarfile
import os
import urllib2
import shutil


METAPHLAN2_URL = 'https://bitbucket.org/biobakery/metaphlan2/get/2.6.0.tar.gz'


def download_file(url, target=None, wd=None):
    """Download a file from a URL
    Fetches a file from the specified URL.
    If 'target' is specified then the file is saved to this
    name; otherwise it's saved as the basename of the URL.
    If 'wd' is specified then it is used as the 'working
    directory' where the file will be save on the local
    system.
    Returns the name that the file is saved with.
    """
    print "Downloading %s" % url
    if not target:
        target = os.path.basename(url)
    if wd:
        target = os.path.join(wd, target)
    print "Saving to %s" % target
    open(target, 'wb').write(urllib2.urlopen(url).read())
    return target

def unpack_tar_archive(filen, wd=None):
    """Extract files from a TAR archive
    Given a TAR archive (which optionally can be
    compressed with either gzip or bz2), extract the
    files it contains and return a list of the
    resulting file names and paths.
    'wd' specifies the working directory to extract
    the files to, otherwise they are extracted to the
    current working directory.
    Once all the files are extracted the TAR archive
    file is deleted from the file system.
    """
    file_list = []
    if not tarfile.is_tarfile(filen):
        print "%s: not TAR file"
        return [filen]
    t = tarfile.open(filen)
    t.extractall(".")
    print "Removing %s" % filen
    os.remove(filen)
    return file_list

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Download MetaPhlAn2 database')
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



