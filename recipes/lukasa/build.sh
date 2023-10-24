#!/bin/bash

WORKFLOW_DIR=$PREFIX/share/lukasa
mkdir -p $WORKFLOW_DIR
cwltool --pack protein_evidence_mapping.cwl >lukasa.cwl
cp lukasa.cwl $WORKFLOW_DIR/

mkdir -p $PREFIX/bin/
cp lukasa.py $PREFIX/bin/