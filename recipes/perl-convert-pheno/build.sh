#!/bin/bash

# install dependencies not found in conda channels
install_deps() {
    deps=(
        "Data::Leaf::Walker"
        # "JSON::Validator"
        "File::ShareDir::ProjectDistDir"
        "Moo"
        "Path::Tiny"
        "Test::Deep"
        "Text::CSV_XS"
        "Text::Similarity"
        "Types::Standard"
        "XML::Fast"
        "YAML::XS"
    )
    for dep in "${deps[@]}"; do
        HOME=/tmp cpanm -v "$dep" || {
        # cpanm "$dep" || {
            echo "Failed to install perl module $dep"
            exit 1
        }
    done
}

if [[ "$(uname)" == Darwin ]]; then
    # potential fix for the compilation errors
    export HOME=`pwd`
    conda install -c bioconda perl-test-leaktrace -y
    conda install -c bioconda perl-params-util -y
    conda install -c conda-forge perl-data-optlist -y
    conda install -c bioconda perl-sub-exporter -y
    conda install -c bioconda perl-mac-systemdirectory -y
    conda install -c bioconda perl-file-homedir -y
    # conda install -c conda-forge perl-yaml-libyaml=0.85 -y
fi

cpanm File::ShareDir::Install
install_deps
perl Makefile.PL INSTALLDIRS=site
make
# make test
make test TEST_FILES="t/mapping.t t/module.t t/ohdsi.t t/stream.t"
make install

# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate";
do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
done
echo "#!/bin/sh" > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "export PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0/" >> "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "#!/bin/sh" > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
echo "unset PERL5LIB" >> "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
