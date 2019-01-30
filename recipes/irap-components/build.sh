mkdir -p $PREFIX/bin

# Deploy activation / deactivation scripts
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/activate.sh" "$PREFIX/etc/conda/activate.d/$PKG_NAME-setenv.sh"
mkdir -p "$PREFIX/etc/conda/deactivate.d"
cp "$RECIPE_DIR/deactivate.sh" "$PREFIX/etc/conda/deactivate.d/$PKG_NAME-restoreenv.sh"

echo "$SRC_DIR/scripts/irap_install.sh -c $PREFIX/bin/irap"

export IRAP_DIR=$PREFIX/bin/irap

# iRAP's install script installs too much stuff, even specifying -c. We'll
# manage dependencies outside of iRAP for now we just copy the files. 
#$SRC_DIR/scripts/irap_install.sh -s $SRC_DIR -c $PREFIX/bin/irap

cp -rp $SRC_DIR $PREFIX/bin/irap
sh_location=$(which sh)
ln -s $sh_location /bin/sh
chmod +x $PREFIX/bin/irap

# Run tests
source "$RECIPE_DIR/activate.sh"           
# make test 
source "$RECIPE_DIR/deactivate.sh"         
