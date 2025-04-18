set -e

# Configuration
N_FILES_IN_TAR=307538
DB_URL="https://data.gtdb.ecogenomic.org/releases/release226/226.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r226_data.tar.gz"
TARGET_TAR_NAME="gtdbtk_r226_data.tar.gz"

# Script variables (no need to configure)
TARGET_DIR=${1:-$GTDBTK_DATA_PATH}
TARGET_TAR="${TARGET_DIR}/${TARGET_TAR_NAME}"

# Check if this is overriding an existing version
mkdir -p "$TARGET_DIR"
n_folders=$(find "$TARGET_DIR" -maxdepth 1 -type d | wc -l)
if [ "$n_folders" -gt 1 ]; then
  echo "[ERROR] - The GTDB-Tk database directory must be empty, please empty it: $TARGET_DIR"
  exit 1
fi

# Start the download process
# Note: When this URL is updated, ensure that the "--total" flag of TQDM below is also updated
echo "[INFO] - Downloading the GTDB-Tk database to: ${TARGET_DIR}"
wget $DB_URL -O "$TARGET_TAR"

# Uncompress and pipe output to TQDM
echo "[INFO] - Extracting archive..."
tar xvzf "$TARGET_TAR" -C "${TARGET_DIR}" --strip 1 | tqdm --unit=file --total=$N_FILES_IN_TAR --smoothing=0.1 >/dev/null

# Remove the file after successful extraction
rm "$TARGET_TAR"
echo "[INFO] - The GTDB-Tk database has been successfully downloaded and extracted."

# Set the environment variable
if conda env config vars set GTDBTK_DATA_PATH="$TARGET_DIR"; then
  echo "[INFO] - Added GTDBTK_DATA_PATH ($TARGET_DIR) to the GTDB-Tk conda environment."
else
  echo "[INFO] - Conda not found in PATH, please be sure to set the GTDBTK_DATA_PATH environment variable"
  echo "export GTDBTK_DATA_PATH=$TARGET_DIR before running GTDB-Tk. "
fi

exit 0
