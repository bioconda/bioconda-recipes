#!/usr/bin/env python3
import os
import re
import sys
import yaml
from textwrap import dedent
import tarfile
import urllib.request

# e.g., "========   addCols   ===================================="
re_header = re.compile(r'^=+\s+(?P<program>\w+)\s+=+$')

# e.g.,# "addCols - Sum columns in a text file."
re_summary = re.compile(r'^(?P<program>\w.*?) - (?P<description>.*)$')


def parse_footer(fn):
    """
    Parse the downloaded FOOTER file, which contains a header for each program
    and (usually) a description line.

    Yields either a nested 2-tuple of (header-program-name,
    (description-program-name, description-text)) if a description can be
    found, or a 1-tuple of (header-program-name,) if no description found.
    """
    block = []
    f = open(fn)
    while True:
        line = f.readline()
        if not line:
            break
        m1 = re_header.match(line)
        if m1:
            if block:
                yield block
                block = []
            name = m1.groups()[0]
            block.append(name)
            continue
        m = re_summary.match(line)
        if m:
            if not block:
                continue
            block.append(m.groups())
            yield block
            block = []
    if block:
        yield block


# Identify version of the last available tarball visible on
# http://hgdownload.cse.ucsc.edu/admin/exe and compute its  sha256; place them
# in the ucsc_config.yaml file that looks like:
#
#   version: 332
#   sha256: 8c2663c7bd302a77cdf52b2e9e85e2cd
ucsc_config = yaml.load(open('ucsc_config.yaml'))
VERSION = ucsc_config['version']
SHA256 = ucsc_config['sha256']

# Download tarball if it doesn't exist. Always download FOOTER.
tarball = (
    'http://hgdownload.cse.ucsc.edu/admin/exe/userApps.v{0}.src.tgz'
    .format(VERSION))
if not os.path.exists(os.path.basename(tarball)):
    f = urllib.request.urlopen(tarball)
    of = open(os.path.basename(tarball), "wb")
    of.write(f.read())
    of.close()
f = urllib.request.urlopen('http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/FOOTER')
of = open("FOOTER", "wb")
of.write(f.read())
of.close()

# Different programs are built under different subdirectories in the source. So
# get a directory listing of the tarball
t = tarfile.open(os.path.basename(tarball))
names = [i for i in t.getnames()
         if i.startswith('./userApps/kent/src')]


def program_subdir(program, names):
    """
    Identify the source directory for a program.
    """
    hits = [i for i in names if program in i and t.getmember(i).isdir()]
    if len(hits) == 0:
        return
    top = sorted(hits)[0]

    return top.replace('./userApps/', '')


# relative to where this file lives
recipes_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'recipes')

# Mismatches between what is parsed from FOOTER and where a program lives in
# the source
problematic = {
#    'LiftSpec': 'liftSpec',
}

# Mismatches between the header and the summary; keys are the program name in
# the header and values are the dir in the source code.
resolve_header_and_summary_conflicts = {
    'cpg_lh': 'cpglh',
    'rmFaDups': 'rmFaDups',
    'bedJoinTabOffset': 'bedJoinTabOffset',
    'webSync': 'webSync',
}

# Some programs' descriptions do not meet the regex in FOOTER and therefore
# must be manually assigned.
manual_descriptions = {

    'expMatrixToBarchartBed': dedent(
        """
        Generate a barChart bed6+5 file from a matrix, meta data, and
        coordinates.
        """),

    'pslRc': 'reverse-complement psl',

    'pslMapPostChain': dedent(
        """
        Post genomic pslMap (TransMap) chaining.  This takes transcripts
        that have been mapped via genomic chains adds back in
        blocks that didn't get include in genomic chains due
        to complex rearrangements or other issues.
        """),

    'estOrient': dedent(
        """
        Read ESTs from a database and determine orientation based on
        estOrientInfo table or direction in gbCdnaInfo table.  Update
        PSLs so that the strand reflects the direction of transcription.
        By default, PSLs where the direction can't be determined are dropped.
        """),

    'fetchChromSizes': dedent(
        """
        used to fetch chrom.sizes information from UCSC for the given <db>
        """),

    'overlapSelect': dedent(
        """
        Select records based on overlapping chromosome ranges.  The ranges are
        specified in the selectFile, with each block specifying a range.
        Records are copied from the inFile to outFile based on the selection
        criteria.  Selection is based on blocks or exons rather than entire
        range.
        """),

    'pslCDnaFilter': dedent(
        """
        Filter cDNA alignments in psl format.  Filtering criteria are
        comparative, selecting near best in genome alignments for each given
        cDNA and non-comparative, based only on the quality of an individual
        alignment.
        """),

    'pslHisto': dedent(
        """
        Collect counts on PSL alignments for making histograms. These then be
        analyzed with R, textHistogram, etc.
        """),

    'pslSwap': dedent(
        """
        Swap target and query in psls
        """),

    'pslToBed': dedent(
        """
        transform a psl format file to a bed format file.
        """),  # note for those keeping track, s/tranform/transform

    'paraNodeStop': dedent(
        """
        Shut down parasol node daemons on a list of machines
        """),

    'parasol': dedent(
        """
        Parasol is the name given to the overall system for managing jobs on
        a computer cluster and to this specific command.  This command is
        intended primarily for system administrators.  The 'para' command
        is the primary command for users.
        """),
}

# programs listed in FOOTER that should not be considered a "ucsc utility"
SKIP = [
    'sizeof',
    'calc',
    'ave',
    'gfClient',
    'gfServer',
]

# Some programs need to be built differently. It seems that a subset of
# programs need the "stringify" binary build as well. Or, in the case of
# fetchChromSizes, it's simply a script that needs to be copied.
custom_build_scripts = {
    'fetchChromSizes': 'template-build-fetchChromSizes.sh',
    'pslCDnaFilter': 'template-build-with-stringify.sh',
    'pslMap': 'template-build-with-stringify.sh',
    'overlapSelect': 'template-build-with-stringify.sh',
    'expMatrixToBarchartBed': 'template-build-cp.sh',
    'gensub2': 'template-build-parasol.sh',
    'para': 'template-build-parasol.sh',
    'paraHub': 'template-build-parasol.sh',
    'paraHubStop': 'template-build-parasol.sh',
    'paraNode': 'template-build-parasol.sh',
    'paraNodeStart': 'template-build-parasol.sh',
    'paraNodeStop': 'template-build-parasol.sh',
    'paraNodeStatus': 'template-build-parasol.sh',
    'parasol': 'template-build-parasol.sh',
    'paraTestJob': 'template-build-parasol.sh',
    'bedJoinTabOffset': 'template-build-cp-short.sh',
    'webSync': 'template-build-cp-short.sh',
}

custom_tests = {
    'expMatrixToBarchartBed': 'template-run_test-exit1.sh',
    'bedJoinTabOffset': 'template-run_test-exit1.sh',
    'webSync': 'template-run_test-exit1.sh',
}

custom_meta = {
    'expMatrixToBarchartBed': 'template-meta-with-python.yaml',
    'bedJoinTabOffset': 'template-meta-with-python.yaml',
    'webSync': 'template-meta-with-python.yaml',
}


for block in parse_footer('FOOTER'):
    sys.stderr.write('.')
    # If len == 2, then a description was parsed.
    if len(block) == 2:
        program, summary = block
        program = problematic.get(program, program)
        summary_program, description = summary

        # Some programs have summary lines that look like this:
        #
        #   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format
        #
        # So just get the first word as the program name.
        summary_program = summary_program.split()[0]
        if program != summary_program:
            try:
                program = resolve_header_and_summary_conflicts[program]
            except KeyError:
                raise ValueError(
                    "mismatch in header and summary. header: "
                    "'{0}'; summary: '{1}'"
                    .format(program, summary_program))
        if program in SKIP:
            continue

    # If len == 1 then no description was parsed, so we expect one to be in
    # manual_descriptions.
    else:
        assert len(block) == 1
        program = block[0]
        if program in SKIP:
            continue
        description = manual_descriptions[program]

    # conda package names must be lowercase
    package = 'ucsc-' + program.lower()
    recipe_dir = os.path.join(recipes_dir, package)

    # Identify the subdirectory we need to go to in the build script. In some
    # cases it may not exist, in which case we expect a custom build script.
    subdir = program_subdir(program, names)
    if subdir is None and program not in custom_build_scripts:
        sys.stderr.write(" Skipping {0} ".format(program))
        continue

    if not os.path.exists(recipe_dir):
        os.makedirs(recipe_dir)

    # Fill in templates and write them to recipe dir
    with open(os.path.join(recipe_dir, 'meta.yaml'), 'w') as fout:
        _template = open(
            custom_meta.get(program, 'template-meta.yaml')
        ).read()
        fout.write(
            _template.format(
                program=program,
                package=package,
                summary=description,
                version=VERSION,
                sha256=SHA256,
            )
        )

    with open(os.path.join(recipe_dir, 'build.sh'), 'w') as fout:
        _template = open(
            custom_build_scripts.get(program, 'template-build.sh')
        ).read()

        fout.write(
            _template.format(
                program=program,
                program_source_dir=program_subdir(program, names),
            )
        )

    with open(os.path.join(recipe_dir, 'run_test.sh'), 'w') as fout:
        _template = open(
            custom_tests.get(program, 'template-run_test.sh')
        ).read()
        fout.write(
            _template.format(
                program=program
            )
        )

    with open(os.path.join(recipe_dir, 'include.patch'), 'w') as fout:
        fout.write(open('include.patch').read())

sys.stderr.write('\n')
