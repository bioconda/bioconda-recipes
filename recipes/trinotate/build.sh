#!/bin/bash
set -ex

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

mv util/generate_Trinotate_report.txt util/generate_Trinotate_report.sh
mv util/auto_Trinotate.txt util/auto_Trinotate.sh

# Install the full source tree: the Trinotate driver invokes its loaders,
# report writer and database builder by path relative to itself
# (util/, util/trinotateSeqLoader/, util/admin/), so they must keep that layout.
TRINOTATE_HOME="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${TRINOTATE_HOME}" "${PREFIX}/bin"
cp -rf Trinotate PerlLib util resources testing TrinotateWeb TrinotateWeb.conf run_TrinotateWebserver.pl "${TRINOTATE_HOME}/"
chmod +rx "${TRINOTATE_HOME}/Trinotate"

# Retained for backward compatibility: individual scripts and PerlLib on PATH / in site perl.
mkdir -p perl-build/scripts
cp -rf PerlLib perl-build/lib
cp -rf PerlLib ${PREFIX}/bin
cp -rf testing ${PREFIX}/trinotate-testing

find . -name "*.pl" | grep -v testing | grep -v perl-build | xargs -I {} cp -rf {} perl-build/scripts/
chmod +rx perl-build/scripts/*
cp perl-build/scripts/* ${PREFIX}/bin

cd perl-build
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site
cd ..

# The Trinotate driver itself runs from the source tree.
cat > "${PREFIX}/bin/Trinotate" <<EOW
#!/bin/bash
exec "${TRINOTATE_HOME}/Trinotate" "\$@"
EOW
chmod +x "${PREFIX}/bin/Trinotate"

# TRINOTATE_HOME, as used in the Trinotate documentation (eg. \$TRINOTATE_HOME/util/...)
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
done
cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOA
export TRINOTATE_HOME="${TRINOTATE_HOME}"
EOA
cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOA
unset TRINOTATE_HOME
EOA
