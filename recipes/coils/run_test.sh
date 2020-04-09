#!/bin/sh
set -x -e

ncoils -f < 1srya.fa > result_test.txt

#check result is what we expect
diff result_test.txt 1srya_result.txt
