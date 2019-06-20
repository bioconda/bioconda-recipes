#! /bin/bash
set -x
set -e
fn=rpkmforgenes.py
chmod +x ${fn} && mv ${fn} ${PREFIX}/bin
