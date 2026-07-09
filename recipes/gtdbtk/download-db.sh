set -euo pipefail

# Configuration
N_FILES_IN_TAR=263
DB_URL="https://data.gtdb.aau.ecogenomic.org/releases/release232/232.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r232_data.tar.gz"
TARGET_TAR_NAME="gtdbtk_r232_data.tar.gz"

# Script variables (no need to configure)
TARGET_DIR=${GTDBTK_DATA_PATH:-""}
THREADS=""

# Usage ang flag parsing
usage() {
    echo "Usage: $0 [-d target_dir] [-t threads]"
    echo "  -d: Directory to install GTDB-Tk package (defaults to \$GTDBTK_DATA_PATH)"
    echo "  -t: Number of threads for download/extraction (defaults to auto-detect, cap 8)"
    exit 1
}

while getopts "d:t:h" opt; do
  case $opt in
    d) TARGET_DIR="$OPTARG" ;;
    t) THREADS="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# TARGET_DIR validation
if [ -z "$TARGET_DIR" ]; then
    echo "[ERROR] - No target directory specified and \$GTDBTK_DATA_PATH is not set."
    usage
fi

TARGET_TAR="${TARGET_DIR}/${TARGET_TAR_NAME}"


# Thread Auto-detection logic
if [ -z "$THREADS" ]; then
    N_CORES=$(nproc)
    THREADS=$(( N_CORES > 8 ? 8 : N_CORES ))
    echo "[INFO] - Auto-detected ${THREADS} threads"
else
    echo "[INFO] - Using user-specified ${THREADS} threads"
fi

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
if command -v aria2c >/dev/null 2>&1; then
    echo "[INFO] - Using aria2c"
    aria2c -x "$THREADS" -s "$THREADS" -k 1M -c -d "$TARGET_DIR" -o "$TARGET_TAR_NAME" "$DB_URL"
elif command -v wget >/dev/null 2>&1; then
    echo "[INFO] - aria2c not found, using wget"
    wget -c "$DB_URL" -O "$TARGET_TAR"
else
    echo "[ERROR] - aria2c or wget required."
    exit 1
fi

# Uncompress and pipe output to TQDM
echo "[INFO] - Extracting archive..."
if command -v pigz >/dev/null 2>&1; then
    echo "[INFO] - Using pigz with ${THREADS} threads"
    pigz -dc -p "$THREADS" "$TARGET_TAR" | \
        tar xvf - -C "${TARGET_DIR}" --strip 1 | \
        tqdm --unit=file --total=$N_FILES_IN_TAR --smoothing=0.1 >/dev/null
else
    echo "[INFO] - pigz not found, using gzip"
    gzip -dc "$TARGET_TAR" | \
        tar xvf - -C "${TARGET_DIR}" --strip 1 | \
        tqdm --unit=file --total=$N_FILES_IN_TAR --smoothing=0.1 >/dev/null
fi

# Remove the file after successful extraction
if [ -f "$TARGET_TAR" ]; then
    echo "[INFO] - Removing archive to save space..."
    rm "$TARGET_TAR"
fi
echo "[INFO] - The GTDB-Tk database has been successfully downloaded and extracted."

# Set the environment variable
if conda env config vars set GTDBTK_DATA_PATH="$TARGET_DIR" >/dev/null 2>&1; then
  echo "[INFO] - Added GTDBTK_DATA_PATH to the conda environment."
  echo "[IMPORTANT] - Please run 'conda activate $(basename $CONDA_PREFIX)' to refresh your environment variables."
else
  echo "[INFO] - Conda not found or environment not active."
  echo "Please manually run: export GTDBTK_DATA_PATH=$TARGET_DIR"
fi

exit 0
