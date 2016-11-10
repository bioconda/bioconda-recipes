#!/usr/bin/env perl

my $GD_VERSION = "2.56";

my @items = (
    ["GD", $GD_VERSION],
    ["GD::Polygon", $GD_VERSION],
    ["GD::Polyline", $GD_VERSION],
    ["GD::Simple", $GD_VERSION],
);

foreach $item (@items) {
    my ($module, $expected_version) = @$item;
    print STDERR "Checking '$module' version: ";
    my $actual_version = eval "use $module; $module->VERSION";
    if($@) { die $@; }
    if(defined $actual_version) {
        print STDERR $actual_version;
        if($actual_version == $expected_version) {
            print STDERR " (PASSED)\n";
        }
        else {
            print STDERR " (FAILED)\n";
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
