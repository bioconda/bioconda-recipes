#!/bin/bash

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -rf *.bak
{{ PYTHON }} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
{{ PYTHON }} -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_ner_bc5cdr_md-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
{{ PYTHON }} -m pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.4/en_ner_bionlp13cg_md-0.5.4.tar.gz --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv