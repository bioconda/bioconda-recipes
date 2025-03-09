#!/bin/bash

# Create necessary directories
mkdir -p $PREFIX/bin

mkdir -p $PREFIX/share/metafun_test/{nf_scripts,config,scripts,help}
mkdir -p $PREFIX/share/metafun_test/db
mkdir -p $PREFIX/share/metafun_test/sif_images
chmod 777 $PREFIX/share/metafun_test/db
chmod 777 $PREFIX/share/metafun_test/sif_images

touch $PREFIX/share/metafun_test/sif_images/.placeholder  


# copy help files. 
if [ -d "help" ] && [ "$(ls -A help/* 2>/dev/null)" ]; then
    cp -r help/* $PREFIX/share/metafun_test/help/
fi


# Copy main executable
if [ -f "bin/metafun_test" ]; then
    cp bin/metafun_test $PREFIX/bin/
    chmod +x $PREFIX/bin/metafun_test
else
    # Create metafun executable if it doesn't exist
    cat > $PREFIX/bin/metafun_test << 'EOF'
#!/bin/bash
# metafun entry script

nextflow run $PREFIX/share/metafun_test/nf_scripts/main.nf "$@"
EOF
    chmod +x $PREFIX/bin/metafun_test
fi

# Copy Nextflow scripts
if [ -d "nf_scripts" ] && [ "$(ls -A nf_scripts/*.nf 2>/dev/null)" ]; then
    cp nf_scripts/*.nf $PREFIX/share/metafun_test/nf_scripts/
fi

# Copy config files
if [ -d "config" ] && [ "$(ls -A config/* 2>/dev/null)" ]; then
    cp config/* $PREFIX/share/metafun_test/config/
fi

# Copy scripts
if [ -d "scripts" ] && [ "$(ls -A scripts/* 2>/dev/null)" ]; then
    cp -r scripts/* $PREFIX/share/metafun_test/scripts/
fi

# Copy DB download script
if [ -f "download_db_metafun.py" ]; then
    cp download_db_metafun.py $PREFIX/share/metafun_test/db/
fi

# # Copy SIF images if they exist
# if [ -d "sif_images" ] && [ "$(ls -A sif_images/*.sif 2>/dev/null)" ]; then
#     cp sif_images/*.sif $PREFIX/share/metafun/sif_images/
# fi
