use strict;
use warnings;
use Module::Build;

use 5.32.1;

my $builder = Module::Build->new(
	module_name         => 'Bio::miRNAture',
	license             => 'gpl_3',
	dist_author         => 'Cristian A Velandia Huerto <cristian@bioinf.uni-leipzig.de>',
	dist_version_from   => 'lib/Bio/miRNAture.pm',
    create_makefile_pl  => 0,
    create_readme       => 1,
	release_status      => 'stable',
	build_requires => {
		'Module::Build' => '0.4224',
	},
	configure_requires => {
		'Module::Build' => '0.4224',
	},
	test_requires => {
		'Test::More' => '0',
	},
	requires => {
		'perl' => '5.32.1',
	},
	script_files => [qw(script/miRNAture script/miRNAture.pl script/miRNAnchor.pl script/evaluate_conserved_str.py)],
	add_to_cleanup => [ 'Bio-miRNAture-*' ],
);

$builder->create_build_script();
