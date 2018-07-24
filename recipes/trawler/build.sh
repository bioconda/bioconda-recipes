#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Fix shebangs
sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' bin/*.pl
rm -rf bin/*.bak
chmod a+x bin/*

rm -rf test_data examples
mkdir -p $outdir
cp -r * $outdir

# Short wrapper script
cat > $PREFIX/bin/trawler <<EOF
#!/bin/bash
PERL5LIB=$outdir:$outdir/treg_comparator exec $outdir/bin/trawler.pl "\$@"
EOF
chmod +x $PREFIX/bin/trawler
