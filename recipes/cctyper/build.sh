## Install CCTyper code
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
## Setup the database
## Download and unpack the data from the released CCTyper code
wget https://github.com/Russel88/CRISPRCasTyper/archive/refs/tags/v1.8.0.tar.gz
tar -xvf v1.8.0.tar.gz
## Create a folder in the conda directory to host these files ("cct_data")
mkdir -p "${PREFIX}/cct_data"
## Copy the relevant files, as well as the Profiles folder after uncompressing
cp CRISPRCasTyper-1.8.0/data/*.* ${PREFIX}/cct_data/
tar -xvf CRISPRCasTyper-1.8.0/data/Profiles.tar.gz
mv Profiles/ ${PREFIX}/cct_data/
## Set up the env variable (not sure it's needed, but probably not harmful)
export CCTYPER_DB="${PREFIX}/cct_data/"
## Set up the files needed to update this env variable (CCTYPER_DB) at each activation / deactivation
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
