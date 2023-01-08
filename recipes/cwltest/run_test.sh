#!/bin/sh -ex

mkdir -p bin
ln -s $(command -v cwltool) bin/cwl-runner
chmod a+x bin/cwl-runner
PATH=$PATH:$PWD/bin CWLTOOL_OPTIONS=--no-container python -m pytest --pyargs cwltest -p pytester -o pytester_example_dir=tests/test-data -k 'not test_plugin'

