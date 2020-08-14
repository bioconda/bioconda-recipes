"""
This module cleans up conda CRAN skeletons to make it compliant with
conda-forge requirements.
"""

import os
import re
from itertools import zip_longest
import argparse
import logging

from conda_build.api import skeletonize

from .utils import run, setup_logger

logger = logging.getLogger(__name__)

# Some dependencies are listed in CRAN that are actually in Bioconductor. Use
# this dict to map these to bioconductor package names.
INVALID_NAME_MAP = {
    'r-edger': 'bioconductor-edger',
}

# Raw strings needed to support the awkward backslashes needed when adding the
# command to yaml
gpl2_short = r"  license_family: GPL2"
gpl2_long = r"""
  license_family: GPL2
  license_file: '{{ environ["PREFIX"] }}/lib/R/share/licenses/GPL-2'  # [unix]
  license_file: '{{ environ["PREFIX"] }}\\R\\share\\licenses\\GPL-2'  # [win]
""".strip('\n')

gpl3_short = r"  license_family: GPL3"
gpl3_long = r"""
  license_family: GPL3
  license_file: '{{ environ["PREFIX"] }}/lib/R/share/licenses/GPL-3'  # [unix]
  license_file: '{{ environ["PREFIX"] }}\\R\\share\\licenses\\GPL-3'  # [win]
""".strip('\n')

win32_string = 'number: 0\n  skip: true  # [win32]'


def write_recipe(package, recipe_dir='.', recursive=False, force=False,
                 no_windows=False, **kwargs):
        """
        Call out to to ``conda skeleton cran``.

        Kwargs are accepted for uniformity with
        `bioconductor_skeleton.write_recipe`; the only one handled here is
        ``recursive``.

        Parameters
        ----------

        package : str
            Package name. Can be case-sensitive CRAN name, or sanitized
            "r-pkgname" conda package name.

        recipe_dir : str
            Recipe will be created as a subdirectory in ``recipe_dir``

        recursive : bool
            Add the ``--recursive`` argument to ``conda skeleton cran`` to
            recursively build CRAN recipes.

        force : bool
            If True, then remove the directory ``<recipe_dir>/<pkgname>``, where
            ``<pkgname>`` the sanitized conda version of the package name,
            regardless of which format was provided as ``package``.

        no_windows : bool
            If True, then after creating the skeleton the files are then
            cleaned of any Windows-related lines and the bld.bat file is
            removed from the recipe.
        """
        logger.debug('Building skeleton for %s', package)
        conda_version = package.startswith('r-')
        if not conda_version:
            outdir = os.path.join(
                recipe_dir, 'r-' + package.lower())
        else:
            outdir = os.path.join(
                recipe_dir, package)
        if os.path.exists(outdir):
            if force:
                logger.warning('Removing %s', outdir)
                run(['rm', '-r', outdir], mask=False)
            else:
                logger.warning('%s exists, skipping', outdir)
                return

        try:
            skeletonize(
                package, repo='cran', output_dir=recipe_dir, version=None, recursive=recursive)
            clean_skeleton_files(
                package=os.path.join(recipe_dir, 'r-' + package.lower()),
                no_windows=no_windows)
        except NotImplementedError as e:
            logger.error('%s had dependencies that specified versions: skipping.', package)


def clean_skeleton_files(package, no_windows=True):
    """
    Cleans output files created by ``conda skeleton cran`` to make them
    conda-forge compatible.

    Parameters
    ----------
    package : str
        Package name. Can be case-sensitive CRAN name, or sanitized
        "r-pkgname" conda package name.

    no_windows : bool
        If True, no bld.bat will be created and no ``[win]`` preprocess selectors
        will be added to the yaml
    """
    clean_yaml_file(package, no_windows)
    clean_build_file(package, no_windows)
    clean_bld_file(package, no_windows)


def clean_yaml_file(package, no_windows):
    """
    Cleans the YAML file output by ``conda skeleton cran`` to make it conda-forge
    compatible.

    Parameters
    ----------
    package : str
        Must be sanitized "r-pkgname" package name.

    no_windows : bool
        If True, then adds a "build: skip: True # [win32]" line to skip Windows
        builds.
    """
    path = os.path.join(package, 'meta.yaml')
    with open(path, 'r') as yaml:
        lines = list(yaml.readlines())

        # Remove lines consisting only of comments
        lines = filter_lines_regex(lines, r'^\s*#.*$', '')
        lines = remove_empty_lines(lines)

        # Remove file license
        lines = filter_lines_regex(lines, r' [+|] file LICEN[SC]E', '')

        # Remove file name lines, which aren't needed as of conda-build3
        lines = filter_lines_regex(lines, r'^\s+fn:\s*.*$', '')

        # Replace GPL2 or GPL3 string created by conda skeleton cran with long
        # format
        lines = filter_lines_regex(lines, gpl2_short, gpl2_long)
        lines = filter_lines_regex(lines, gpl3_short, gpl3_long)

        if no_windows:
            # Inserts `skip: true # [win32]` after `number: 0` to skip windows
            # builds
            lines = filter_lines_regex(lines, r'number: 0', win32_string)

        # Add contents of maintainers file to the end of the recipe
        add_maintainers(lines)

    with open(path, 'w') as yaml:
        out = "".join(lines)
        out = out.replace('{indent}', '\n    - ')

        # Edit INVALID_NAME_MAP if additional fixes needed
        for wrong, correct in INVALID_NAME_MAP.items():
            out = out.replace(wrong, correct)
        yaml.write(out)


def clean_build_file(package, no_windows=False):
    """
    Cleans build.sh file created by ``conda skeleton cran`` to be compatible with
    conda-forge.

    Parameters
    ----------
    package : str
        Must be sanitized "r-pkgname" package name.

    no_windows : bool
        Included for consistency with other ``clean_*`` functions; does not have
        any effect for this function.
    """

    path = os.path.join(package, 'build.sh')
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
    """
    Cleans bld.bat file created by ``conda skeleton cran`` to be compatible with
    conda-forge.

    Parameters
    ----------
    package : str
        Must be sanitized "r-pkgname" package name.

    no_windows : bool
        If True, then the bld.bat file will be removed.
    """
    path = os.path.join(package, 'bld.bat')
    if not os.path.exists(path):
        return
    if no_windows:
        os.unlink(path)
        return
    with open(path, 'r') as bld:
        lines = list(bld.readlines())

        # Removes the lines that start with @
        lines = filter_lines_regex(lines, r'^@.*$', '')
        lines = remove_empty_lines(lines)

    with open(path, 'w') as bld:
        bld.write("".join(lines))


def filter_lines_regex(lines, regex, substitute):
    """
    Substitutes **substitute** for every match to **regex** in each line of
    **lines**.

    Parameters
    ----------

    lines : iterable of strings

    regex, substitute : str
    """
    return [re.sub(regex, substitute, line) for line in lines]


def remove_empty_lines(lines):
    """
    Removes consecutive empty lines in **lines**.

    Parameters
    ----------

    lines: iterable of strings
    """
    cleaned_lines = []
    for line, next_line in zip_longest(lines, lines[1:]):
        if (
            (line.isspace() and next_line is None) or
            (line.isspace() and next_line.isspace())
        ):
            pass
        else:
            cleaned_lines.append(line)

    if cleaned_lines[0].isspace():
        cleaned_lines = cleaned_lines[1:]
    return cleaned_lines


def add_maintainers(lines):
    """
    Append the contents of "maintainers.yaml" to the end of a YAML file.
    """
    HERE = os.path.abspath(os.path.dirname(__file__))
    maintainers_yaml = os.path.join(HERE, 'maintainers.yaml')
    with open(maintainers_yaml, 'r') as yaml:
        extra_lines = list(yaml.readlines())
        lines.extend(extra_lines)


def main():
    """ Adding support for arguments here """
    setup_logger()
    parser = argparse.ArgumentParser()
    parser.add_argument('package', help='name of the cran package')
    parser.add_argument('output_dir', help='output directory for the recipe')
    parser.add_argument('--no-win', action="store_true",
                        help='runs the skeleton and removes windows specific information')
    parser.add_argument('--force', action='store_true',
                        help='If a directory exists for any recipe, overwrite it')

    args = parser.parse_args()
    write_recipe(args.package, args.output_dir, no_windows=args.no_win,
                 force=args.force)


if __name__ == '__main__':
    main()
