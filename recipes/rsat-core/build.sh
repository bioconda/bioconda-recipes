

# TODO: better file system layout and entry point command
RSAT_DEST="$PREFIX/opt/rsat/"
mkdir -p "$RSAT_DEST"

cp -a perl-scripts python-scripts makefiles bin/rsat share/rsat/rsat.yaml "$RSAT_DEST"

# echo "#!/bin/sh" > $PREFIX/bin/rsat
# echo "../opt/rsat/rsat" >> $PREFIX/bin/rsat
# chmod 755 $PREFIX/bin/rsat

## Alternative: 
## - au opt: placer les scripts perl, le yaml etc dans usr/share/rsat
## - au dispatcher dans bin: placer dans le bin le script python rsat et lui indiquer où aller pêcher le yaml.

# Build and dispatch compiled binaries
cd contrib
# for dbin in *
for dbin in info-gibbs count-words matrix-scan-quick retrieve-variation-seq variation-scan 
do
    if [ -d "$dbin" ]; then
        cd "$dbin"
        make clean && make CC=$CC CXX=$CXX && cp "$dbin" "$PREFIX/bin"
        cd ..
    fi
done


# TODO: R packaging
