#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $outdir
cp -r * $outdir

# Short wrapper script which sets PERL5LIB while running
cat > $PREFIX/bin/pfam_scan.pl <<EOF
#!/bin/bash
# Last line of script to ensure any failure return code is passed on:
PERL5LIB=$outdir:$outdir/treg_comparator exec $outdir/pfam_scan.pl "\$@"
EOF
chmod +x $PREFIX/bin/pfam_scan.pl
