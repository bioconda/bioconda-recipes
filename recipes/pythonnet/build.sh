#!/bin/bash

cert-sync $PREFIX/ssl/cacert.pem

$PYTHON setup.py install 

