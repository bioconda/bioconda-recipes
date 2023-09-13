#! /bin/bash
set -x
set -e
fn=rpkmforgenes.py
mkdir -p ${PREFIX}/bin
chmod +x ${fn} && mv ${fn} ${PREFIX}/bin
