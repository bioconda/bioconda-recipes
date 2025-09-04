#!/bin/bash

# Create destination directories
mkdir -p $PREFIX/bin/scripts
mkdir -p $PREFIX/bin/data
mkdir -p $PREFIX/bin/output
mkdir -p $PREFIX/bin/taxonomy_files

# Copy main scripts to bin directory
cp -rf config.pl $PREFIX/bin/
cp -rf main.pl $PREFIX/bin/

# Copy all scripts from scripts directory
cp -rf scripts/*.py scripts/*.sh $PREFIX/bin/scripts/

# Make all scripts executable
chmod +x $PREFIX/bin/config.pl
chmod +x $PREFIX/bin/main.pl
chmod +x $PREFIX/bin/scripts/*.sh
chmod +x $PREFIX/bin/scripts/*.py

# Create README with information about database download
cat > $PREFIX/bin/README.txt << EOF
HYMET - Hybrid Metagenomic Tool

After installation, you need to download the reference sketched databases from:
https://drive.google.com/drive/folders/1YC0N77UUGinFHNbLpbsucu1iXoLAM6lm

Download the files:
- sketch1.msh.gz
- sketch2.msh.gz
- sketch3.msh.gz

Place these files in the 'data' directory and unzip them:

gunzip data/sketch1.msh.gz
gunzip data/sketch2.msh.gz
gunzip data/sketch3.msh.gz

Then run:
./config.pl
./main.pl
EOF

# Create wrapper scripts that point to the installed location
cat > $PREFIX/bin/hymet-config << EOF
#!/bin/bash
cd $PREFIX/bin
perl config.pl \$@
EOF

cat > $PREFIX/bin/hymet << EOF
#!/bin/bash
cd $PREFIX/bin
perl main.pl \$@
EOF

# Make wrapper scripts executable
chmod +x $PREFIX/bin/hymet-config
chmod +x $PREFIX/bin/hymet 
