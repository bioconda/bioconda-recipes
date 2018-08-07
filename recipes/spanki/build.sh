#!/bin/bash
sed -i.bak "s:/usr/bin/perl:/usr/bin/env perl:" bin/*.pl
rm bin/*.bak
chmod a+rx bin/*
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
