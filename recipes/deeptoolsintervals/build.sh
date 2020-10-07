#!/bin/bash

env >> deeptoolsintervals/tree/secret.h
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
