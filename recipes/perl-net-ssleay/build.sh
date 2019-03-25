#!/bin/bash

export OPENSSL_PREFIX=${PREFIX}

export PERL_MM_USE_DEFAULT=1

if [ `uname -s` == "Darwin" ]; then
    # Force use of conda's OpenSSL instead of the system one
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    # Force use of conda's OpenSSL instead of the system one
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

perl -V
wrong_prefix="$(perl -V | sed -rn "s|\s+cc='([^']+)/bin/.*|\1|p")"
if test -n "$wrong_prefix"; then
  echo "Perl has broken build env prefix. Fixing..."
  good_prefix="${CC%/bin/*}"
  echo "Replacing"
  echo "  $wrong_prefix"
  echo "with"
  echo "  $good_prefix"
  grep -rlI "$wrong_prefix" $(perl -e 'print "@INC"') | \
      sort -u |\
      xargs sed -ibak "s|$wrong_prefix|$good_prefix|g"
  if perl -V | grep "$wrong_prefix"; then
     echo "Failed to fix paths - expect breakage below"
  else
      echo "Sucesss!"
  fi
fi
perl -V

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
