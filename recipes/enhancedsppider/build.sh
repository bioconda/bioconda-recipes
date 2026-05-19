#!/bin/bash
set -ex

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/enhancedsppider/scripts

cp -r scripts/* $PREFIX/share/enhancedsppider/scripts/

# Create entry scripts
cat > $PREFIX/bin/sppIDer << 'EOF'
#!/bin/bash
python $CONDA_PREFIX/share/enhancedsppider/scripts/sppIDer.py "$@"
EOF
chmod +x $PREFIX/bin/sppIDer

cat > $PREFIX/bin/combineRefGenomes << 'EOF'
#!/bin/bash
python $CONDA_PREFIX/share/enhancedsppider/scripts/combineRefGenomes.py "$@"
EOF
chmod +x $PREFIX/bin/combineRefGenomes

cat > $PREFIX/bin/extractReadsBySpecies << 'EOF'
#!/bin/bash
python $CONDA_PREFIX/share/enhancedsppider/scripts/extractReadsBySpecies.py "$@"
EOF
chmod +x $PREFIX/bin/extractReadsBySpecies
