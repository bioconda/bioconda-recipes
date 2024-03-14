# Install paragone
$PYTHON -m pip install --no-deps --ignore-installed .

# Install HmmCleaner:
${PREFIX}/bin/perl ${PREFIX}/bin/cpanm Bio::MUST::Core --notest
${PREFIX}/bin/perl ${PREFIX}/bin/cpanm Bio::MUST::Drivers --notest
${PREFIX}/bin/perl ${PREFIX}/bin/cpanm --force Bio::MUST::Apps::HmmCleaner --notest

sed -i 's|#!/opt/miniconda3/miniconda3/bin/env perl|#!/usr/bin/env perl|' ${PREFIX}/bin/HmmCleaner.pl
