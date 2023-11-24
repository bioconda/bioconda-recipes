# Install paragone
$PYTHON -m pip install --no-deps --ignore-installed .

# Install Net::SSLeay
# ${PREFIX}/bin/perl ${PREFIX}/bin/cpanm --configure-args="INC='/usr/include/x86_64-linux-gnu'" Net::SSLeay --notest

# Install HmmCleaner:
${PREFIX}/bin/perl ${PREFIX}/bin/cpanm Bio::MUST::Core --notest
${PREFIX}/bin/perl ${PREFIX}/bin/cpanm Bio::MUST::Drivers --notest
${PREFIX}/bin/perl ${PREFIX}/bin/cpanm --force Bio::MUST::Apps::HmmCleaner --notest

sed -i 's|#!/opt/miniconda3/miniconda3/bin/env perl|#!/usr/bin/env perl|' ${PREFIX}/bin/HmmCleaner.pl

# Install FastTreeMP
# curl -OL http://www.microbesonline.org/fasttree/FastTree.c
# gcc -DOPENMP -fopenmp -O3 -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm
# cp FastTreeMP ${PREFIX}/bin

# Install TreeShrink
# git clone https://github.com/uym2/TreeShrink.git
# cd TreeShrink
# $PYTHON -m pip install .
# cd ..

# sed -i 's|import csv|import csv\nif sys.version_info.major == 3 and sys.version_info.minor >= 10:\n\tfrom collections.abc import MutableMapping\nelse:\n\tfrom collections import MutableMapping|' $STDLIB_DIR/site-packages/dendropy/utility/container.py

# sed -i 's|CaseInsensitiveDict(collections.MutableMapping)|CaseInsensitiveDict(MutableMapping)|' $STDLIB_DIR/site-packages/dendropy/utility/container.py