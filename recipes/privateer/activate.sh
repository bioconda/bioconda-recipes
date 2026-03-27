export PRIVATEERDATA="${CONDA_PREFIX}/share/privateer/privateer_data"
export PRIVATEERRESULTS="${CONDA_PREFIX}/share/privateer/results"
export CLIBD_MON="${PRIVATEERDATA}/monomers/"

mkdir -p "${PRIVATEERDATA}"
mkdir -p "${PRIVATEERRESULTS}"
mkdir -p "${CLIBD_MON}"

echo "\`PRIVATEERDATA\` is set to: ${PRIVATEERDATA}."
echo "\`PRIVATEERRESULTS\` is set to: ${PRIVATEERRESULTS}."
echo "\`CLIBD_MON\` is set to: ${CLIBD_MON}."
