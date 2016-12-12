#!/usr/bin/env perl

my @items = (
    ["Template", "2.26"],
    ["Template::Base", "2.78"],
    ["Template::Config", "2.75"],
    ["Template::Constants", "2.75"],
    ["Template::Context", "2.98"],
    ["Template::Directive", "2.2"],
    ["Template::Document", "2.79"],
    ["Template::Exception", "2.7"],
    ["Template::Filters", "2.87"],
    ["Template::Grammar", "2.26"],
    ["Template::Iterator", "2.68"],
    ["Template::Namespace::Constants", "1.27"],
    ["Template::Parser", "2.89"],
    ["Template::Plugin", "2.7"],
    ["Template::Plugin::Assert", "1"],
    ["Template::Plugin::CGI", "2.7"],
    ["Template::Plugin::Datafile", "2.72"],
    ["Template::Plugin::Date", "2.78"],
    ["Template::Plugin::Directory", "2.7"],
    ["Template::Plugin::Dumper", "2.7"],
    ["Template::Plugin::File", "2.71"],
    ["Template::Plugin::Filter", "1.38"],
    ["Template::Plugin::Format", "2.7"],
    ["Template::Plugin::HTML", "2.62"],
    ["Template::Plugin::Image", "1.21"],
    ["Template::Plugin::Iterator", "2.68"],
    ["Template::Plugin::Math", "1.16"],
    #["Template::Plugin::Pod", "2.26"],
    ["Template::Plugin::Procedural", "1.17"],
    ["Template::Plugin::Scalar", "1"],
    ["Template::Plugin::String", "2.4"],
    ["Template::Plugin::Table", "2.71"],
    ["Template::Plugin::URL", "2.74"],
    ["Template::Plugin::View", "2.68"],
    ["Template::Plugin::Wrap", "2.68"],
    ["Template::Plugins", "2.77"],
    ["Template::Provider", "2.94"],
    ["Template::Service", "2.8"],
    ["Template::Stash", "2.91"],
    ["Template::Stash::Context", "1.63"],
    ["Template::Stash::XS", undef],
    ["Template::Test", "2.75"],
    ["Template::VMethods", "2.16"],
    ["Template::View", "2.91"],
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
