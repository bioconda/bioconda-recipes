#!/bin/bash

bioconda/bioconda-utils dag --format dot --hide-singletons . | twopi -Npenwidth=0 -Nfixedsize=shape -Nwidth=0.3 -Nfillcolor="#00000055" -Ecolor="#00000055" -Nshape=circle -Nstyle=filled -Nlabel="" -Tsvg  > dag.svg
