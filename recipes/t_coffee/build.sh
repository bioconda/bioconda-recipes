#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

TCOFFEE_FOLDER_NAME="${PKG_NAME}-${PKG_VERSION}"
TCOFFEE_INSTALL_PATH="$PREFIX/lib/$TCOFFEE_FOLDER_NAME"

if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"
    mkdir -p $TCOFFEE_INSTALL_PATH
    mkdir -p $TCOFFEE_INSTALL_PATH/bin
    
    ./install t_coffee -tcdir=$TCOFFEE_INSTALL_PATH/ -exec=$TCOFFEE_INSTALL_PATH/bin/ 
    cp -rf "$RECIPE_DIR/t_coffee" "$TCOFFEE_INSTALL_PATH"
    ln -s "$TCOFFEE_INSTALL_PATH/t_coffee" "$SP_DIR/t_coffee"
    sed -i "s|{{TCOFFEE_FOLDER_NAME}}|$TCOFFEE_FOLDER_NAME|g" "$TCOFFEE_INSTALL_PATH/t_coffee/config.py"
    find $TCOFFEE_INSTALL_PATH

    
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"

    chmod +x T-COFFEE_installer_Version_11.00.8cbe486_linux_x64.bin
    ./T-COFFEE_installer_Version_11.00.8cbe486_linux_x64.bin \
        --prefix "$TCOFFEE_INSTALL_PATH" \
        --mode unattended \
        --user_email username@hostname.com

    cp -rf "$RECIPE_DIR/t_coffee" "$TCOFFEE_INSTALL_PATH"
    ln -s "$TCOFFEE_INSTALL_PATH/t_coffee" "$SP_DIR/t_coffee"
    sed -i "s|{{TCOFFEE_FOLDER_NAME}}|$TCOFFEE_FOLDER_NAME|g" "$TCOFFEE_INSTALL_PATH/t_coffee/config.py"
fi
