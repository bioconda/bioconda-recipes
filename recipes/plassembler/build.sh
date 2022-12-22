python3 -m pip install . --no-deps -vv 

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/bin/plassemblerModules/"

cp -r plassembler.py $PREFIX/bin/
cp -r plassemblerModules/* $PREFIX/bin/plassemblerModules/

