#!/usr/bin/env bash
set -eo pipefail
python -c 'import pytaxonkit; print(pytaxonkit.__version__)'
python -c 'import pytaxonkit; print(pytaxonkit._get_taxonkit_version())'
