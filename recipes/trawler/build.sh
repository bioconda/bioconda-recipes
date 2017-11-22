#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# See https://github.com/Ramialison-Lab-ARMI/Trawler-2.0/issues/1
# Fix space in some hash-bang lines,
sed -i.bak 's|#! usr/bin/perl|#!/usr/bin/env perl|' bin/*.pl
# Fix hash-bang lines not to use system Perl,
sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' bin/*.pl
rm -rf bin/*.bak

rm -rf test_data examples
mkdir -p $outdir
cp -r * $outdir

# Short wrapper script
cat > $PREFIX/bin/trawler <<EOF
#!/bin/bash
PERL5LIB=$outdir:$outdir/treg_comparator exec $outdir/bin/trawler.pl "\$@"
EOF
chmod +x $PREFIX/bin/trawler
