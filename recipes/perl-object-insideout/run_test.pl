#!/usr/bin/env perl 
# Test loading of Object::InsideOut. Need a script as it cannot be loaded from
# the main package as conda-build would do.

use strict;
use warnings;



package My::PackageName::Noone::Else::Is::Using;

use Object::InsideOut;

# EOF

