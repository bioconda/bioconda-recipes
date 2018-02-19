#!/usr/bin/env python3

import argparse
import bz2
import os
import requests
import shutil
import tarfile
import io


METAPHLAN2_URL = 'https://bitbucket.org/biobakery/metaphlan2/downloads/mpa_v20_m200.tar'


def download_file(url):
    """Download a file from a URL

    :param url: URL of the file to download

    :return: Path to downloaded file
    """
    print("Downloading %s" % url)
    r = requests.get(url, stream=True)
    r.raise_for_status()

    target = os.path.basename(url)
    print("Saving to %s" % target)
    with open(target, "wb") as fd:
        for chunk in r.iter_content(chunk_size=128):
            fd.write(chunk)
    return target


def unpack_tar_archive(filepath):
    """Extract files from an archive
    
    Given an archive (which optionally can be compressed with either gzip or 
    bz2), extract the files it contains and return a list of the resulting file 
    names and paths.
    
    Once all the files are extracted the archive file is deleted from the 
    file system.

    :param filepath: path to an archive
    """
    print("Extract %s" % filepath)
    with tarfile.open(filepath, "r") as t:
        t.extractall(".")
    print("Removing %s" % filepath)
    os.remove(filepath)


def unpack_bz2_archive(in_filepath, out_filepath):
    """Extract files from an archive
    
    Given an archive (which optionally can be compressed with either gzip or 
    bz2), extract the files it contains and return a list of the resulting file 
    names and paths.
    
    Once all the files are extracted the archive file is deleted from the 
    file system.

    :param in_filepath: path to a BZ2 archive
    :param out_filepath: path to a output file
    """    
    print("Extract %s" % in_filepath)
    with bz2.BZ2File(in_filepath, 'rb') as fin, open(out_filepath, "w") as fout:
        with io.TextIOWrapper(fin, encoding='utf-8') as dec:
            fout.write(dec.read())
    print("Removing %s" % in_filepath)
    os.remove(in_filepath)


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
    unpack_tar_archive(metaphlan2_tarfile)
    unpack_bz2_archive("mpa_v20_m200.fna.bz2", "mpa_v20_m200.fna")

    shutil.move("mpa_v20_m200.pkl", output)
    shutil.move("mpa_v20_m200.fna", output)
