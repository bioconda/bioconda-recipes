# stop on error
set -eu -o pipefail

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OUT="${PREFIX}/share/${VERSION}"
PATH="$PATH:$OUT/core_lib/wrapper/"

# copy the files to /share/${VERSION}
mkdir -p "${OUT}"
mkdir -p "${PREFIX}/bin"
cp -R * "${OUT}/"

# remove the GNU mac binary and install it using conda
rm "${OUT}/core_lib/external/getopt_mac"

# use the javafx library installed by conda
rm -r "${OUT}/jars/libs/modules/"

# rename the sh scripts
mv "${OUT}/watchdog.sh" "${OUT}/watchdog-cmd.sh"
mv "${OUT}/workflowDesigner.sh" "${OUT}/watchdog-gui.sh"

# create symbolic links and make them executable
ln -s "${OUT}/watchdog-cmd.sh" "${PREFIX}/bin/watchdog-cmd"
ln -s "${OUT}/watchdog-gui.sh" "${PREFIX}/bin/watchdog-gui"
chmod 0755 "${PREFIX}/bin/watchdog-cmd"
chmod 0755 "${PREFIX}/bin/watchdog-gui"

# create additional symbolic links for JAR files and helper scripts
source "${OUT}/helper_scripts/watchdogLauncher.sh" "${PREFIX}/bin"
