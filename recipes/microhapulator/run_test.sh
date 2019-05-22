#!/usr/bin/env bash
set -eo pipefail

mhpl8r getrefr
pytest -m 'not known_failing' --cov=microhapulator --pyargs microhapulator
rm $(mhpl8r getrefr --path)
