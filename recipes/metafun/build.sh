#!/bin/bash

# Create necessary directories
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/metafun/{nf_scripts,config,scripts,help}
mkdir -p $PREFIX/share/metafun/db
mkdir -p $PREFIX/share/metafun/sif_images
chmod 777 $PREFIX/share/metafun/db
chmod 777 $PREFIX/share/metafun/sif_images

touch $PREFIX/share/metafun/sif_images/.placeholder  

# copy help files
if [ -d "help" ] && [ "$(ls -A help/* 2>/dev/null)" ]; then
    cp -r help/* $PREFIX/share/metafun/help/
fi

# Copy main executable
if [ -f "bin/metafun" ]; then
    cp bin/metafun $PREFIX/bin/
    chmod +x $PREFIX/bin/metafun
else
    # Create metafun executable if it doesn't exist
    cat > $PREFIX/bin/metafun << 'INNEREOF'
#!/bin/bash
# metafun entry script

nextflow run $PREFIX/share/metafun/nf_scripts/main.nf "$@"
INNEREOF
    chmod +x $PREFIX/bin/metafun
fi

# Copy Nextflow scripts
if [ -d "nf_scripts" ] && [ "$(ls -A nf_scripts/*.nf 2>/dev/null)" ]; then
    cp -r nf_scripts/* $PREFIX/share/metafun/nf_scripts/
fi

# Copy config files
if [ -d "config" ] && [ "$(ls -A config/* 2>/dev/null)" ]; then
    cp -r config/* $PREFIX/share/metafun/config/
fi

# Copy scripts
if [ -d "scripts" ] && [ "$(ls -A scripts/* 2>/dev/null)" ]; then
    cp -r scripts/* $PREFIX/share/metafun/scripts/
fi

# Copy DB download script
if [ -f "download_db_metafun.py" ]; then
    cp download_db_metafun.py $PREFIX/share/metafun/db/
fi