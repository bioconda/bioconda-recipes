#!/bin/sh

rapidnj -h 2> test_stderr.txt || true && diff help.e test_stderr.txt
