# stop on error
set -eu -o pipefail

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OUT="${PREFIX}/share/${VERSION}"

# copy the files to /share/${VERSION}
mkdir -p "${OUT}"
mkdir -p "${PREFIX}/bin"
cp -R * "${OUT}/"

# rename the sh scripts
mv "${OUT}/watchdog.sh" "${OUT}/watchdog-cmd.sh"
mv "${OUT}/workflowDesigner.sh" "${OUT}/watchdog-gui.sh"

# modify path of included files
sed -i "s|\$SCRIPT_FOLDER/|\$SCRIPT_FOLDER/../share/${VERSION}/|g" "${OUT}/watchdog-cmd.sh"

# create symbolic links and make them executable
ln -s "${OUT}/watchdog-cmd.sh" "${PREFIX}/bin/watchdog-cmd"
ln -s "${OUT}/watchdog-gui.sh" "${PREFIX}/bin/watchdog-gui"
chmod 0755 "${PREFIX}/bin/watchdog-cmd"
chmod 0755 "${PREFIX}/bin/watchdog-gui"
