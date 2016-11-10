#!/usr/bin/env perl

my @items = (
    ["GD", undef],
    ["GD::Polygon", undef],
    ["GD::Polyline", undef],
    ["GD::Simple", undef],
);

foreach $item (@items) {
    my ($module, $expected_version) = @$item;
    print STDERR "Checking '$module' version: ";
    my $actual_version = eval "use $module; $module->VERSION";
    if($@) { die $@; }
    if(defined $actual_version) {
        print STDERR $actual_version;
        if($actual_version == $expected_version) {
            print STDERR " $actual_version (PASSED)\n";
        }
        else {
            print STDERR " $actual_version (FAILED)\n";
            die("$module: Expected version '$expected_version', " .
                "but found '$actual_version'.")
        }
    }
    elsif(defined $expected_version) {
        print STDERR "<not available> (FAILED)\n";
        die("$module: Expected version '$expected_version', " .
            "but found none");
    }
    else {
        print STDERR "<not checked> (PASSED)\n";
    }
}
