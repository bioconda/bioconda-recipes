#!/usr/bin/env bash

echo "Downloading MyDbFinder database to ${MyDbFinder_DB}..."

cd ${MyDbFinder_DB}
# download MyDbfinder database
git clone https://git@bitbucket.org/genomicepidemiology/mydbfinder_db.git
cd mydbfinder_db
kma_index -i listeria_virulence_genes.fsa
kma_index -i vibrio_cholerae.fsa
cd ..

echo "MyDbFinder database is downloaded."

exit 0
