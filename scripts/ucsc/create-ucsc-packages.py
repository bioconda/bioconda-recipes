#!/usr/bin/env python
import os
import re
import tarfile
from conda.fetch import download


def parse_footer(fn):
    for line in open(fn):
        m = re_summary.match(line)
        if not m:
            continue
        yield m.groups()


re_summary = re.compile(r'^(?P<program>\w.*?) - (?P<description>.*)$')

# This is the version of the last available tarball visible on
# http://hgdownload.cse.ucsc.edu/admin/exe/
VERSION = "324"

tarball = 'http://hgdownload.cse.ucsc.edu/admin/exe/userApps.v{0}.src.tgz'.format(VERSION)
if not os.path.exists(os.path.basename(tarball)):
    download(tarball, os.path.basename(tarball))

# Different programs are built under different subdirectories in the source. So
# get a directory listing of the tarball
t = tarfile.open(os.path.basename(tarball))
names = [i for i in t.getnames()
         if i.startswith('./userApps/kent/src')]

def program_subdir(program, names):
    hits = [i for i in names if program in i and t.getmember(i).isdir() ]
    if len(hits) == 0:
        return
    top = sorted(hits)[0]

    return top.replace('./userApps/', '')


download('http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/FOOTER', 'FOOTER')

meta_template = open('template-meta.yaml').read()
build_template = open('template-build.sh').read()
test_template = open('template-run_test.sh').read()

# relative to where this file lives
recipes_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'recipes')

# Mismatches between what is parsed from FOOTER and where a program lives in
# the source
problematic = {
    'LiftSpec': 'liftSpec',
}

for program, summary in parse_footer('FOOTER'):

    # some programs -- like bedGraphToBigWig -- have summary lines that
    # look like this:
    #
    #   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format
    #
    # So just get the first word as the program name.
    program = program.split()[0]

    program = problematic.get(program, program)

    # conda package names must be lowercase
    package = 'ucsc-' + program.lower()
    recipe_dir = os.path.join(recipes_dir, package)

    subdir = program_subdir(program, names)
    if subdir is None:
        print("Skipping {0}".format(program))
        continue

    if not os.path.exists(recipe_dir):
        os.makedirs(recipe_dir)

    # Fill in templates and write them to recipe dir
    with open(os.path.join(recipe_dir, 'meta.yaml'), 'w') as fout:
        fout.write(
            meta_template.format(
                program=program,
                package=package,
                summary=summary,
                version=VERSION,
            )
        )

    with open(os.path.join(recipe_dir, 'build.sh'), 'w') as fout:
        fout.write(
            build_template.format(
                program=program,
                program_source_dir=program_subdir(program, names),
            )
        )

    with open(os.path.join(recipe_dir, 'run_test.sh'), 'w') as fout:
        fout.write(
            test_template.format(
                program=program
            )
        )

    with open(os.path.join(recipe_dir, 'include.patch'), 'w') as fout:
        fout.write(open('include.patch').read())
