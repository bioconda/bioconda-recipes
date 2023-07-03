#!/bin/bash
export PERL5LIB="$CONDA_PREFIX/lib:$CONDA_PREFIX/lib/perl5:$CONDA_PREFIX/lib/perl5/site_perl:$PERL5LIB"

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