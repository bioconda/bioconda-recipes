#!/usr/bin/env bash
set -vex
cd pb-falcon

mkdir -p pypeflow
tar xvfz pypeflow*.tar.gz --strip=1 -C pypeflow
pushd pypeflow
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
popd

mkdir -p falcon_kit
tar xvfz falcon_kit*.tar.gz --strip=1 -C falcon_kit
pushd falcon_kit
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
popd

mkdir -p falcon_unzip
tar xvfz falcon_unzip*.tar.gz --strip=1 -C falcon_unzip
pushd falcon_unzip
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
popd

mkdir -p falcon_phase
tar xvfz falcon_phase*.tar.gz --strip=1 -C falcon_phase
pushd falcon_phase
$PYTHON setup.py install --single-version-externally-managed --record=/tmp/record.txt
popd
