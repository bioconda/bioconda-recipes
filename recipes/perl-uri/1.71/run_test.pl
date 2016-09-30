#!/usr/bin/env perl

my @items = (
    ["URI", "1.71"],
    ["URI::Escape", "3.31"],
    ["URI::Heuristic", "4.20"],
    ["URI::IRI", "1.71"],
    ["URI::QueryParam", "1.71"],
    ["URI::Split", "1.71"],
    ["URI::URL", "5.04"],
    ["URI::WithBase", "2.20"],
    ["URI::data", "1.71"],
    ["URI::file", "4.21"],
    ["URI::file::Base", "1.71"],
    ["URI::file::FAT", "1.71"],
    ["URI::file::Mac", "1.71"],
    ["URI::file::OS2", "1.71"],
    ["URI::file::QNX", "1.71"],
    ["URI::file::Unix", "1.71"],
    ["URI::file::Win32", "1.71"],
    ["URI::ftp", "1.71"],
    ["URI::gopher", "1.71"],
    ["URI::http", "1.71"],
    ["URI::https", "1.71"],
    ["URI::ldap", "1.71"],
    ["URI::ldapi", "1.71"],
    ["URI::ldaps", "1.71"],
    ["URI::mailto", "1.71"],
    ["URI::mms", "1.71"],
    ["URI::news", "1.71"],
    ["URI::nntp", "1.71"],
    ["URI::pop", "1.71"],
    ["URI::rlogin", "1.71"],
    ["URI::rsync", "1.71"],
    ["URI::rtsp", "1.71"],
    ["URI::rtspu", "1.71"],
    ["URI::sftp", "1.71"],
    ["URI::sip", "1.71"],
    ["URI::sips", "1.71"],
    ["URI::snews", "1.71"],
    ["URI::ssh", "1.71"],
    ["URI::telnet", "1.71"],
    ["URI::tn3270", "1.71"],
    ["URI::urn", "1.71"],
    ["URI::urn::oid", "1.71"],
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
