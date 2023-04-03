#!/usr/bin/env perl

my @items = (
    ["SOAP::Lite", "1.27"],
);

print "\n";
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
