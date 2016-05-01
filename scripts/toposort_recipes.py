#!/usr/bin/env python
"""
This script can be useful when creating a large number of recipes that, if
submitted all at once, could result in timeout errors when building on
travis-ci. A common example is when recipes must be updated for a new
Bioconductor release. This script batches together recipes such that each batch
does not depend on any recipes in subsequent batches.

For example, upon updating recipes for a new version of bioconductor, find all
the relevant recipes:

    ./toposort_recipes.py --repository .. --only-modified -s="bioconductor-*' -s="r-*"

Then grab everything up to the first "---" (this is the first batch) and commit
them. Then submit a PR for travis-ci to try testing these packages. Rinse and
repeat using subsequent batches.

"""
import utils
import argparse
ap = argparse.ArgumentParser()
ap.add_argument('--only-modified', action='store_true', help='Only list '
                'recipes changed according to git status')
ap.add_argument('--subset', '-s', action='append', help='Pattern to subset by. '
                'Can be specified multiple times. Default is "%(default)s"')
ap.add_argument('--repository', required=True, help='Path to top-level dir of '
                'repository')
args = ap.parse_args()

subset = args.subset or "*"

for sorted_subdag in utils.toposort_recipes(
    repository=args.repository,
    subset=subset,
    only_modified=args.only_modified
):
    print('\n'.join(sorted_subdag))
    print('---')
