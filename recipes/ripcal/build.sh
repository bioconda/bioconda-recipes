#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Creating necessary directories
mkdir -p "${PREFIX}/bin"

# Copying executable files to bin directory
cp "${SRC_DIR}/perl/"* "${PREFIX}/bin/"

# Fixing permissions
chmod +x "${PREFIX}/bin/deripcal"
chmod +x "${PREFIX}/bin/ripcal"
chmod +x "${PREFIX}/bin/ripcal_summarise"

sed -i "s:/usr/bin/perl:/usr/bin/env perl:" "${PREFIX}/bin/ripcal"
sed -i "s/use Bio::Perl;/use BioPerl;/" "${PREFIX}/bin/ripcal"

sed -i "s:/usr/bin/perl:/usr/bin/env perl:" "${PREFIX}/bin/deripcal"
sed -i "s:/usr/bin/perl:/usr/bin/env perl:" "${PREFIX}/bin/ripcal_summarise"

export "PERL5LIB=${PREFIX}/lib/perl5/site_perl/5.32.1/:${PERL5LIB}"

sed -i.bak '/^use Tk/ s/^/# /' "${PREFIX}/bin/ripcal"

