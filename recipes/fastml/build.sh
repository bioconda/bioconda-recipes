#!/bin/bash
set -e -x -o pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-c++11-narrowing"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-c++11-narrowing"

make CC="$CXX" CXX="$CXX" -j"${CPU_COUNT}"

FASTDAT="$PREFIX/share/fastml"
mkdir -p "$FASTDAT/programs/fastml" "$FASTDAT/programs/indelCoder" \
         "$FASTDAT/programs/gainLoss" "$FASTDAT/www" "$PREFIX/bin"

# Compiled binaries, keeping the source-relative layout:
# FastML_Wrapper.pl and IndelReconstruction_Wrapper.pl resolve
# $Bin/../../programs/<tool>/<tool>
install -v -m 0755 programs/fastml/fastml         "$FASTDAT/programs/fastml"
install -v -m 0755 programs/indelCoder/indelCoder "$FASTDAT/programs/indelCoder"
install -v -m 0755 programs/gainLoss/gainLoss     "$FASTDAT/programs/gainLoss"

# Perl wrapper chain + bundled perl modules, keeping the layout:
# FastML_Wrapper.pl does "use lib $Bin/../bioSequence_scripts_and_constants/"
cp -rf www/fastml $FASTDAT/www/
cp -rf www/bioSequence_scripts_and_constants $FASTDAT/www/

# CLI entry points
ln -sf $FASTDAT/programs/fastml/fastml         $PREFIX/bin/fastml
ln -sf $FASTDAT/programs/indelCoder/indelCoder $PREFIX/bin/indelCoder
ln -sf $FASTDAT/programs/gainLoss/gainLoss     $PREFIX/bin/gainLoss

# Main entry point: a perl shim that exec's the real script inside
# share/fastml, so FindBin's $Bin resolves within the installed tree
# and every relative path above keeps working. The shim itself must be
# valid perl so that "perl FastML_Wrapper.pl ..." keeps working too.
#
# The shim locates itself with FindBin instead of hardcoding $PREFIX, so
# it stays correct wherever the package is unpacked and does not depend on
# conda-build's prefix rewriting. Quoted heredoc: no shell expansion, so
# perl sigils like $^X / @ARGV need no escaping.
cat > $PREFIX/bin/FastML_Wrapper.pl <<'EOF'
#!/usr/bin/env perl
use FindBin;
exec($^X, "$FindBin::Bin/../share/fastml/www/fastml/FastML_Wrapper.pl", @ARGV)
    or die "exec FastML_Wrapper failed\n";
EOF
chmod +x $PREFIX/bin/FastML_Wrapper.pl
