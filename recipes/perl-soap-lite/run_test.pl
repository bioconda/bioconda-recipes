#!/usr/bin/env perl

my @items = (
    ["SOAP::Lite", "1.19"],
    ["SOAP::Lite::Deserializer::XMLSchema1999", undef],
    ["SOAP::Lite::Deserializer::XMLSchema2001", undef],
    ["SOAP::Lite::Deserializer::XMLSchemaSOAP1_1", undef],
    ["SOAP::Lite::Deserializer::XMLSchemaSOAP1_2", undef],
    ["SOAP::Lite::Packager", undef],
    ["SOAP::Lite::Utils", undef],
    ["SOAP::Packager", "1.17"],
    ["SOAP::Test", "1.17"],
    ["SOAP::Transport::HTTP", "1.17"],
    ["SOAP::Transport::IO", "1.17"],
    ["SOAP::Transport::LOCAL", "1.17"],
    ["SOAP::Transport::LOOPBACK", undef],
    ["SOAP::Transport::MAILTO", "1.17"],
    ["SOAP::Transport::POP3", "1.17"],
    ["SOAP::Transport::TCP", "1.17"],
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
