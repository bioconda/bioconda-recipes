#!/bin/bash
#sed -i.bak 's#!/usr/bin/env python -Es#!/usr/bin/env python#' scripts/bcbio_vm.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
