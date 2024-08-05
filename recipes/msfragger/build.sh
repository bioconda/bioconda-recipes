#!/bin/bash

# These values are submitted to the MSFragger site when downloading the application zip.
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
cp "$RECIPE_DIR/msfragger.py" "$TARGET"
ln -s "$TARGET/msfragger.py" "$PREFIX/bin/msfragger"
chmod 0755 "${PREFIX}/bin/msfragger"

# This script automates accepting the academic license agreements in order to download MSFragger and build the package. A user of this package is then expected to accept the terms themselves when they download a license key from the MSFragger site, which is enforced by the wrapper script and MSFragger jar file.
"${RECIPE_DIR}/academic_install.py" -n galaxy -e "$EMAIL" -o "$INSTITUTION" -m "$PKG_VERSION" -p "$TARGET" --hash "$SHA256SUM"
if [[ $? -ne 0 ]]; then
    echo "Problem downloading jar file." > /dev/stderr
    exit 1;
fi

# Unzip and link jar.
cd "$TARGET"
unzip "MSFragger-$PKG_VERSION.zip"
ln -s "MSFragger-$PKG_VERSION/MSFragger-$PKG_VERSION.jar" "MSFragger.jar"
rm "MSFragger-$PKG_VERSION.zip"
