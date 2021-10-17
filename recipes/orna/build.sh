chmod 755 *
bash install.sh
mkdir -p "${PREFIX}/bin"
mv build/bin/ORNA "$PREFIX/bin/"
