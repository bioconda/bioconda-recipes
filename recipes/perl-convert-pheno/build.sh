#!/bin/bash

# install dependencies not found in conda channels
install_deps() {
    deps=(
        "File::ShareDir::ProjectDistDir"
        "JSON::Validator"
        "Moo"
        "Path::Tiny"
        "Test::Deep"
        "Test::Warn"
        "Text::CSV_XS"
        "Text::Similarity"
        "Types::Standard"
        "XML::Fast"
        "YAML::XS"
    )
    for dep in "${deps[@]}"; do
        HOME=/tmp cpanm "$dep" || {
            echo "Failed to install perl module $dep"
            exit 1
        }
    done
}
install_deps
perl Makefile.PL INSTALLDIRS=site
make
# make test
make install

# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate";
do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
  #cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
echo "#!/bin/sh" > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "export PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0/" >> "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "#!/bin/sh" > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
echo "unset PERL5LIB" >> "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"