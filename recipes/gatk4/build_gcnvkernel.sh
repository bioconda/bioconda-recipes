#!/bin/bash

unzip -q gatkPythonPackageArchive.zip '*gcnvkernel*'
$PYTHON setup_gcnvkernel.py install --single-version-externally-managed --record=record_gcnvkernel.txt
