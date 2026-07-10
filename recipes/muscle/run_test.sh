#!/bin/bash

muscle -msastats test_data.fna
muscle -super5 test_data.fna -output test_output.fna
cat test_output.fna
