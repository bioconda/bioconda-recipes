#!/bin/bash
set -vex

cd pb-falcon

mkdir -p pypeflow
tar xvfz pypeflow*.tar.gz --strip=1 -C pypeflow
pushd pypeflow
sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -f *.bak
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir --use-pep517 -vvv
popd

mkdir -p falcon_kit
tar xvfz falcon_kit*.tar.gz --strip=1 -C falcon_kit
pushd falcon_kit
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir --use-pep517 -vvv
popd

mkdir -p falcon_unzip
tar xvfz falcon_unzip*.tar.gz --strip=1 -C falcon_unzip
pushd falcon_unzip
sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -f *.bak
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir --use-pep517 -vvv
popd

mkdir -p falcon_phase
tar xvfz falcon_phase*.tar.gz --strip=1 -C falcon_phase
pushd falcon_phase
sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -f *.bak
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir --use-pep517 -vvv
popd
