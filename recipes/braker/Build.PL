use strict;
use warnings;

use Module::Build 0.28;

my @files = glob q("*pl script/*pl bin/*pl");

foreach my $file (@files){
    my $tfile = "$file.t";
    print STDERR "Change shebang line to #!perl $file\n";
    open my $in,  "<$file" or die $!;
    open my $out, ">$tfile" or die $!;
    while (<$in>) {
        s|^#!/usr/bin/perl -w|#!perl|;    # so MakeMaker can fix it
        s|^#!/usr/bin/env perl|#!perl|;    # so MakeMaker can fix it
        s|^#!/usr/bin/perl|#!perl|;    # so MakeMaker can fix it
        print $out $_;
    }
    close($in);
    close($out);
    system("mv $tfile $file");
}

my %module_build_args = (
    "build_requires"     => { "Module::Build" => "0.28" },
    "configure_requires" => { "Module::Build" => "0.28" },
    "dist_abstract"      => "Base Build Script for perl scripts",
    "dist_author"          => [ "Jillian Rowe <jillian.e.rowe\@gmail.com>" ],
    "dist_name"            => "Bioconda Perl Execs",
    "dist_version"         => "1.9",
    "license"              => "perl",
    "module_name"          => "Bioconda Perl Execs",
    "recursive_test_files" => 1,
    "requires"             => { "perl" => "5.008005" },
    "script_files"         => \@files,
    "test_requires"        => {
        "Capture::Tiny" => 0,
        "Test::More"    => 0,
        "strict"        => 0
    }
);

my %fallback_build_requires = (
    "Capture::Tiny" => 0,
    "Module::Build" => "0.28",
    "Test::More"    => 0,
    "strict"        => 0
);

unless ( eval { Module::Build->VERSION(0.4004) } ) {
    delete $module_build_args{test_requires};
    $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
