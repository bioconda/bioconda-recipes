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

# rename the sh scripts
mv "${OUT}/watchdog.sh" "${OUT}/watchdog-cmd.sh"
mv "${OUT}/workflowDesigner.sh" "${OUT}/watchdog-gui.sh"

# create symbolic links and make them executable
cd "${PREFIX}"
ln -s "${OUT}/watchdog-cmd.sh" "bin/watchdog-cmd"
ln -s "${OUT}/watchdog-gui.sh" "bin/watchdog-gui"
chmod 0755 "bin/watchdog-cmd"
chmod 0755 "bin/watchdog-gui"

# create additional symbolic links for JAR files and helper scripts
source "${OUT}/helper_scripts/watchdogLauncher.sh" "bin/"
