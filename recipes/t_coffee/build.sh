#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

TCOFFEE_FOLDER_NAME="${PKG_NAME}-${PKG_VERSION}"
TCOFFEE_INSTALL_PATH="$PREFIX/lib/$TCOFFEE_FOLDER_NAME"

chmod +x T-COFFEE_installer_Version_*_linux_x64.bin
./T-COFFEE_installer_Version_*_linux_x64.bin \
    --prefix "$TCOFFEE_INSTALL_PATH" \
    --mode unattended \
    --user_email username@hostname.com

cp -rf "$RECIPE_DIR/t_coffee" "$TCOFFEE_INSTALL_PATH"
ln -s "$TCOFFEE_INSTALL_PATH/t_coffee" "$SP_DIR/t_coffee"
sed -i "s|{{TCOFFEE_FOLDER_NAME}}|$TCOFFEE_FOLDER_NAME|g" "$TCOFFEE_INSTALL_PATH/t_coffee/config.py"

