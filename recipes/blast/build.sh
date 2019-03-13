#!/bin/bash

cp $SRC_DIR/bin/* $PREFIX/bin/

chmod +x $PREFIX/bin/*
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/update_blastdb.pl
