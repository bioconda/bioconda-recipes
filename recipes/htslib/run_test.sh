#!/bin/bash
./tabix 2>&1 | grep "tabix"
./bgzip 2>&1 | grep "bgzip"
./htsfile 2>&1 | grep "htsfile"
