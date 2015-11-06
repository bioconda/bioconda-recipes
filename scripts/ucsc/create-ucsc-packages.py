#!/usr/bin/env python
import os
import re

re_summary = re.compile('^(?P<program>.*) - (?P<description>.*)')

# This is the version of the last available tarball visible on
# http://hgdownload.cse.ucsc.edu/admin/exe/
VERSION = "323"

def parse_footer(fn):
    for line in open(fn):
        m = re_summary.match(line)
        if not m:
            continue
        yield m.groups()

if __name__ == "__main__":
    meta_template = open('template-meta.yaml').read()
    build_template = open('template-build.sh').read()
    test_template = open('template-run_test.sh').read()

    # relative to where this file lives
    recipes_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'recipes')

    # FOOTER is from:
    # http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/FOOTER
    for program, summary in parse_footer('FOOTER'):

        # some programs -- like bedGraphToBigWig -- have summary lines that
        # look like this:
        #
        #   bedGraphToBigWig v 4 - Convert a bedGraph file to bigWig format
        #
        # So just get the first word as the program name.
        program = program.split()[0]

        # conda package names must be lowercase
        package = 'ucsc-' + program.lower()
        recipe_dir = os.path.join(recipes_dir, package)

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
                    program=program)
            )

        with open(os.path.join(recipe_dir, 'run_test.sh'), 'w') as fout:
            fout.write(
                test_template.format(
                    program=program
                )
            )

        with open(os.path.join(recipe_dir, 'include.patch'), 'w') as fout:
            fout.write(open('include.patch').read())
