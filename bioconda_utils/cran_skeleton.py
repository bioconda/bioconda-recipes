from optparse import OptionParser
import subprocess as sp
import re
from itertools import zip_longest
import argparse
import yaml


INVALID_NAME_MAP = {
    'r-edger': 'bioconductor-edger',
}

gpl2_short = r"  license_family: GPL2"
gpl2_long = ("  license_family: GPL2\n  license_file: '{{ environ[\"PREFIX\"] }}" +
             "\/lib\/R\/share\/licenses\/GPL-2'  # [unix]\n  " +
             "license_file: '{{ environ[\"PREFIX\"] }}" +
             "\\\R\\\share\\\licenses\\\GPL-2'  # [win]")

gpl3_short = r"  license_family: GPL3"
gpl3_long = ("  license_family: GPL3\n  license_file: '{{ environ[\"PREFIX\"] }}" +
             "\/lib\/R\/share\/licenses\/GPL-3'  # [unix]\n  " +
             "license_file: '{{ environ[\"PREFIX\"] }}" +
             "\\\R\\\share\\\licenses\\\GPL-3'  # [win]")

win32_string = 'number: 0\n  skip: true  # [win32]'


def write_recipe(package, recipe_dir='.', no_windows=True, config=None, force=False, bioc_version=None,
                 pkg_version=None, versioned=False, recursive=False, seen_dependencies=[]):
        if recursive:
            sp.call(['conda skeleton cran ' + package + ' --output-dir ' + recipe_dir + " --recursive"], shell=True)
        else:
            sp.call(['conda skeleton cran ' + package + ' --output-dir ' + recipe_dir], shell=True)


def clean_skeleton_files(package, no_windows=True):
    # Cleans the yaml and build files to make them conda-forge compatible.

    clean_yaml_file(package, no_windows)
    clean_build_file(package, no_windows)
    clean_bld_file(package, no_windows)


def clean_yaml_file(package, no_windows):
    path = package + '/meta.yaml'
    with open(path, 'r') as yaml:
        lines = list(yaml.readlines())
        lines = filter_lines_regex(lines, r'^\s*#.*$', '')  # Removes the lines consisting of only comments
        lines = remove_empty_lines(lines)
        lines = filter_lines_regex(lines, r' [+|] file LICEN[SC]E', '')  # remove file license
        lines = filter_lines_regex(lines, gpl2_short, gpl2_long)  # add gpl 2
        lines = filter_lines_regex(lines, gpl3_short, gpl3_long)  # add gpl 3
        if no_windows:
            lines = filter_lines_regex(lines, r'number: 0', win32_string)  # Inserts the skip: true # [win32] after number: 0, to skip windows builds
        add_maintainers(lines)

    with open(path, 'w') as yaml:
        out = "".join(lines)
        out = out.replace('{indent}', '\n    - ')
        for wrong, correct in INVALID_NAME_MAP.items():
            out = out.replace(wrong, correct)
        yaml.write(out)


def clean_build_file(package, no_windows=False):
    # Clean build.sh file

    path = package + '/build.sh'
    with open(path, 'r') as build:
        lines = list(build.readlines())
        # Remove lines with mv commands
        lines = filter_lines_regex(lines, r'^mv\s.*$', '')
        # Remove lines with grep commands
        lines = filter_lines_regex(lines, r'^grep\s.*$', '')
        # Removes the lines consisting of only comments
        lines = filter_lines_regex(lines, r'^\s*#.*$', '')
        lines = remove_empty_lines(lines)

    with open(path, 'w') as build:
        build.write("".join(lines))


def clean_bld_file(package, no_windows):
    # Clean bld.bat file

    path = package + '/bld.bat'
    with open(path, 'r') as bld:
        lines = list(bld.readlines())
        # Removes the lines that start with @
        lines = filter_lines_regex(lines, r'^@.*$', '')
        lines = remove_empty_lines(lines)

    with open(path, 'w') as bld:
        bld.write("".join(lines))


def filter_lines_regex(lines, regex, substitute):
    return [re.sub(regex, substitute, line) for line in lines]


def remove_empty_lines(lines):
    # Removes consecutive empty lines from a file

    cleaned_lines = []

    for line, next_line in zip_longest(lines, lines[1:]):
        if (line.isspace() and next_line is None) or (line.isspace() and next_line.isspace()):
            pass
        else:
            cleaned_lines.append(line)

    if cleaned_lines[0].isspace():
        cleaned_lines = cleaned_lines[1:]
    return cleaned_lines


def add_maintainers(lines):
    with open("maintainers.yaml", 'r') as yaml:
        extra_lines = list(yaml.readlines())
        lines.extend(extra_lines)


def main():
    """ Adding support for arguments here """
    parser = argparse.ArgumentParser()
    parser.add_argument('package', help='name of the cran package')
    parser.add_argument('output_dir', help='output directory for the recipe')
    parser.add_argument('--no-win', default=False, action="store_true",
                        help='runs the skeleton and removes windows specific information')

    args = parser.parse_args()
    write_recipe(args.package, args.output_dir, no_windows=args.no_win)


if __name__ == '__main__':
    main()
