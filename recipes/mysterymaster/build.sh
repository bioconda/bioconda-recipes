#!/bin/bash
mkdir -p "$PREFIX/bin"

cp FindBarcodes $PREFIX/bin/

mkdir -p "$PREFIX/lib"
cp -r data/ $PREFIX/lib/
cp mysterymaster.cfg $PREFIX/lib/
cp MysteryMasterGUI.jar $PREFIX/lib/

echo '#!/bin/bash' > ${PREFIX}/bin/mysterymaster
echo 'for arg in "$@"; do [[ "$arg" == "-h" || "$arg" == "--help" ]] && echo "Run the mysterymaster GUI" && exit 0; done' >> $PREFIX/bin/mysterymaster
echo 'java -jar "'$PREFIX'/lib/MysteryMasterGUI.jar" "$@"' >> $PREFIX/bin/mysterymaster
chmod +x "${PREFIX}/bin/mysterymaster"
