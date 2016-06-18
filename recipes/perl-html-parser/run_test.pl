#!/usr/bin/env perl

my @items = (
    ["HTML::Entities", "3.69"],
    ["HTML::Filter", "3.72"],
    ["HTML::HeadParser", "3.71"],
    ["HTML::LinkExtor", "3.69"],
    ["HTML::Parser", "3.72"],
    ["HTML::PullParser", "3.57"],
    ["HTML::TokeParser", "3.69"],
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
