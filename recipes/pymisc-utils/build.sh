#!/bin/bash
$PYTHON setup.py install
cp misc 
chmod 755 ${PREFIX}/bin/*.py
