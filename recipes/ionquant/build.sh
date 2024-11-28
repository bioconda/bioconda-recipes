#!/bin/bash

# These values are submitted to the IonQuant site when downloading the application zip.
if [[ -z "$NAME" ]]; then
    NAME="${USERNAME:-bioconda}";
fi
if [[ -z "$EMAIL" ]]; then
    EMAIL="${NAME}@${HOSTNAME:-bioconda.org}";
fi
if [[ -z "$INSTITUTION" ]]; then
    INSTITUTION="${HOSTNAME:-bioconda.org}";
fi

# Create directories
TARGET="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p "$TARGET"

# Add wrapper python script and link to unprefixed name.
cp "$RECIPE_DIR/ionquant.py" "$TARGET"
ln -s "$TARGET/ionquant.py" "$PREFIX/bin/ionquant"
chmod 0755 "${PREFIX}/bin/ionquant"

# This script automates accepting the academic license agreements in order to download the software and build the package. A user of this package is then expected to accept the terms themselves when they download a license key from the IonQuant site, which is enforced by the wrapper script and IonQuant jar file.
"${RECIPE_DIR}/academic_install.py" -n galaxy -e "$EMAIL" -o "$INSTITUTION" -i "$PKG_VERSION" -p "$TARGET" --hash "$SHA256SUM"
if [[ $? -ne 0 ]]; then
    echo "Problem downloading jar file." > /dev/stderr
    exit 1;
fi

# Unzip and link jar.
cd "$TARGET"
unzip "IonQuant-$PKG_VERSION.zip"
ln -s "IonQuant-$PKG_VERSION/IonQuant-$PKG_VERSION.jar" "IonQuant.jar"
rm "IonQuant-$PKG_VERSION.zip"
