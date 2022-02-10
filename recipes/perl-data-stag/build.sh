#!/bin/bash

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

chmod +rx $PREFIX/bin/stag-mogrify.pl
chmod +rx $PREFIX/bin/stag-grep.pl
chmod +rx $PREFIX/bin/stag-findsubtree.pl
chmod +rx $PREFIX/bin/stag-itext2sxpr.pl
chmod +rx $PREFIX/bin/stag-autoschema.pl
chmod +rx $PREFIX/bin/stag-splitter.pl
chmod +rx $PREFIX/bin/stag-join.pl
chmod +rx $PREFIX/bin/stag-filter.pl
chmod +rx $PREFIX/bin/stag-query.pl
chmod +rx $PREFIX/bin/stag-drawtree.pl
chmod +rx $PREFIX/bin/stag-handle.pl
chmod +rx $PREFIX/bin/stag-parse.pl
chmod +rx $PREFIX/bin/stag-flatten.pl
chmod +rx $PREFIX/bin/stag-merge.pl
chmod +rx $PREFIX/bin/stag-itext2xml.pl
chmod +rx $PREFIX/bin/stag-db.pl
chmod +rx $PREFIX/bin/stag-xml2itext.pl
chmod +rx $PREFIX/bin/stag-view.pl
chmod +rx $PREFIX/bin/stag-itext2simple.pl
chmod +rx $PREFIX/bin/stag-diff.pl
