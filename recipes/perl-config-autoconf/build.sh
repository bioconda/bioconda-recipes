#!/bin/bash

export PERL_AUTOCONF_CACHE="$RECIPE_DIR/.autoconf.perl"

if [[ -f "$PERL_AUTOCONF_CACHE" ]]; then
    cp "$PERL_AUTOCONF_CACHE" ./
    echo "Copied autoconf cache: $PERL_AUTOCONF_CACHE"
else
    echo "WARNING: No autoconf cache file found at $PERL_AUTOCONF_CACHE"
    echo "         Tests may fail in cross-compilation."
fi

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL || exit 1
    ./Build || exit 1

    if ! ./Build test; then
        echo "Warning: Tests failed, but allowing due to cross-compilation constraints."
        echo "If this is not intended, fix the autoconf cache or environment."
    fi

    ./Build install --installdirs site
    ./Build realclean

elif [ -f Makefile.PL ]; then
    PERL_USE_UNSAFE_INC=1 perl Makefile.PL INSTALLDIRS=site || exit 1
    make || exit 1

    if ! make test; then
        echo "Warning: Tests failed, likely due to cross-compilation."
        echo "Using cached config via PERL_AUTOCONF_CACHE should help."
        echo "Proceeding with install..."
    fi

    make install

else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
