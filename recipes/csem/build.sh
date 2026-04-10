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

# Fix the hardcoded -lz to point to Conda's library folder
sed -i "s|-lz|-L${PREFIX}/lib -lz|g" makefile

# Disable the curses TUI in the bundled samtools (not needed)
sed -i "s|-D_CURSES_LIB=1|-D_CURSES_LIB=0|" sam/Makefile
sed -i "s|LIBCURSES=\t-lcurses.*|LIBCURSES=\t-L${PREFIX}/lib|" sam/Makefile

# Run Make, overriding their custom variables with Conda's paths
make \
    CC="${CC}" \
    CXX="${CXX}" \
    COFLAGS="-Wall -O3 -c -I. -I${PREFIX}/include" \
    CFLAGS="-g -Wall -O2 -I${PREFIX}/include -fcommon" \
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# --- Install binaries and Perl module ---
mkdir -p "${PREFIX}/bin"
cp csem csem-bam2wig csem-bam-processor csem-generate-input run-csem "${PREFIX}/bin/"

# --- Install Perl module to site lib directory ---
PERL_LIB=$(perl -MConfig -e 'print $Config{installsitelib}')
mkdir -p "${PERL_LIB}"
cp csem_perl_utils.pm "${PERL_LIB}/"
