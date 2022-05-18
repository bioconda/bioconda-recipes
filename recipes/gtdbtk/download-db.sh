set -e

# Configuration
N_FILES_IN_TAR=139919
DB_URL="https://data.gtdb.ecogenomic.org/releases/release207/207.0/auxillary_files/gtdbtk_r207_v2_data.tar.gz"
TARGET_TAR_NAME="gtdbtk_r207_v2_data.tar.gz"

# Script variables (no need to configure)
TARGET_TAR="${GTDBTK_DATA_PATH}/${TARGET_TAR_NAME}"

# Check if this is overriding an existing version
mkdir -p "$GTDBTK_DATA_PATH"
n_folders=$(find "$GTDBTK_DATA_PATH" -maxdepth 1 -type d | wc -l)
if [ "$n_folders" -gt 1 ]; then
  echo "This will remove the previous GTDB-Tk database under $GTDBTK_DATA_PATH, proceed?"
  read -p "Proceed? [y/N] " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Removing previous version of GTDB-Tk database..."
    rm -rf "$GTDBTK_DATA_PATH"
  else
    echo
    echo "Exiting..."
    exit 1
  fi
fi

# Ensure that the GTDB-Tk data directory exists
mkdir -p "$GTDBTK_DATA_PATH"

# Start the download process
# Note: When this URL is updated, ensure that the "--total" flag of TQDM below is also updated
echo "Downloading the GTDB-Tk database to: ${GTDBTK_DATA_PATH}"
wget $DB_URL -O "$TARGET_TAR"

# Uncompress and pipe output to TQDM
echo "Extracting archive..."
tar xvzf "$TARGET_TAR" -C "${GTDBTK_DATA_PATH}" --strip 1 | tqdm --unit=file --total=$N_FILES_IN_TAR --smoothing=0.1 >/dev/null

# Remove the file after successful extraction
rm "$TARGET_TAR"
echo "GTDB-Tk database has been successfully downloaded and extracted."

# Set the environment variable
conda env config vars set GTDBTK_DATA_PATH="$GTDBTK_DATA_PATH"

exit 0

