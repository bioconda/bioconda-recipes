#!/bin/bash

mkdir -p ${PREFIX}/bin
sed -i.bak "s:/usr/bin/perl:/usr/bin/env perl:" *.pl
chmod 0755 *.pl
cp *.pl ${PREFIX}/bin/
