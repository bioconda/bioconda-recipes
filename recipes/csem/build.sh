#!/bin/bash
set -euo pipefail

# --------------------------------------------------------------------------
# Compiler layout in CSEM makefiles:
#   makefile        — CC = g++  (compiles/links C++ code, calls sam sub-make)
#   sam/Makefile    — CC = gcc  (compiles C code, propagates CC to subdirs)
#   sam/bcftools/   — CC = gcc  (receives CC from parent)
#   sam/misc/       — CC = gcc  (receives CC from parent)
#
# Strategy: patch the hardcoded values in the makefiles so the conda-build
# toolchain compilers ($CXX for C++, $CC for C) are used throughout.
# --------------------------------------------------------------------------

# --- Root makefile: replace g++ with conda CXX ---
sed -i "1s|CC = g++|CC = ${CXX}|" makefile
# Add conda include path
sed -i "s|COFLAGS = -Wall -O3 -c -I\.|COFLAGS = -Wall -O3 -c -I. -I${PREFIX}/include|" makefile
# Add conda lib path for linking (all occurrences of -lz)
sed -i "s|-lz|-L${PREFIX}/lib -lz|g" makefile

# --- sam/Makefile: replace gcc with conda CC ---
sed -i "1s|CC=\t\t*gcc|CC=\t\t${CC}|" sam/Makefile
# Add conda include paths
sed -i "s|CFLAGS=\t\t-g -Wall -O2|CFLAGS=\t\t-g -Wall -O2 -I${PREFIX}/include -I${PREFIX}/include/ncurses|" sam/Makefile
# Replace -lcurses with -lncurses and add conda library path
sed -i "s|LIBCURSES=\t-lcurses|LIBCURSES=\t-L${PREFIX}/lib -lncurses|" sam/Makefile

# --- sam/bcftools/Makefile: replace gcc with conda CC ---
sed -i "1s|CC=\t\t*gcc|CC=\t\t${CC}|" sam/bcftools/Makefile

# --- sam/misc/Makefile: replace gcc and g++ with conda compilers ---
sed -i "1s|CC=\t\t*gcc|CC=\t\t${CC}|" sam/misc/Makefile
sed -i "2s|CXX=\t\t*g++|CXX=\t\t${CXX}|" sam/misc/Makefile

# --- Build ---
make

# --- Install binaries and Perl module ---
mkdir -p "${PREFIX}/bin"
cp csem csem-bam2wig csem-bam-processor csem-generate-input run-csem "${PREFIX}/bin/"

# install perl module into perl's site/vendor lib
perl -e 'use Config; print "$Config{vendorarch}\n"'
PERL_VENDORARCH="$(perl -MConfig -e 'print $Config{vendorarch}')"
mkdir -p "${PREFIX}/${PERL_VENDORARCH}"
cp csem_perl_utils.pm "${PREFIX}/${PERL_VENDORARCH}/"
