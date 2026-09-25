echo "Setting up CCTyper database"
## Setup the database
## Download and unpack the data from the released CCTyper code
curl -O -L https://github.com/Russel88/CRISPRCasTyper/archive/refs/tags/v1.8.0.tar.gz
tar -xvf v1.8.0.tar.gz
## Create a folder in the conda directory to host these files ("cct_data")
mkdir -p "${PREFIX}/cct_data"
## Copy the relevant files, as well as the Profiles folder after uncompressing
cp CRISPRCasTyper-1.8.0/data/*.* ${PREFIX}/cct_data/
tar -xvf CRISPRCasTyper-1.8.0/data/Profiles.tar.gz
mv Profiles/ ${PREFIX}/cct_data/
## Set up the env variable (not sure it's needed, but probably not harmful)
export CCTYPER_DB="${PREFIX}/cct_data/"
echo "CCTyper database is now available in ${CCTYPER_DB}"
