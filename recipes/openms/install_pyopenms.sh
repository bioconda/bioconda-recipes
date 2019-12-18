#!/bin/bash
# TODO actually it would be better if we could adapt our MANIFEST.in
# to not package the openms libs and dependencies again. Same for share.
$PYTHON -m pip install pyOpenMS/ --ignore-installed --no-deps -vv
