#!/usr/bin/env perl

my @items = (
    ["Font::TTF::Cvt_", "0.0001"],
    ["Font::TTF::Font", "0.39"],
    ["Font::TTF::Fpgm", "0.0001"],
    ["Font::TTF::Name", "1.1"],
    ["Font::TTF::Post", "0.01"],
    ["Font::TTF::Prep", "0.0001"],
    ["Font::TTF::Segarr", "0.0001"],
    ["Font::TTF::Table", "0.0001"],
    ["Font::TTF::Ttc", "0.0001"],
    ["Font::TTF::Utils", "0.0001"],
);

foreach $item (@items) {
    my ($module, $expected_version) = @$item;
    print "Checking '$module' version: ";
    my $actual_version = eval "use $module; $module->VERSION";
    if($@) { die $@; }
    if(defined $actual_version) {
        print $actual_version;
        if($actual_version == $expected_version) {
            print " (PASSED)\n";
        }
        else {
            print " (FAILED)\n";
            die("$module: Expected version '$expected_version', " .
                "but found '$actual_version'.")
        }
    }
    elsif(defined $expected_version) {
        print "<not available> (FAILED)\n";
        die("$module: Expected version '$expected_version', " .
            "but found none");
    }
    else {
        print "<not available> (PASSED)\n";
    }
}
