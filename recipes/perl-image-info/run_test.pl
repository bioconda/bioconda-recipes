#!/usr/bin/env perl

my @items = (
    ["Image::Info", "1.38"],
    ["Image::Info::BMP", "1.04"],
    ["Image::Info::GIF", "1.02"],
    #["Image::Info::ICO", "1.38"],
    ["Image::Info::JPEG", "0.05"],
    ["Image::Info::PNG", "1.01"],
    #["Image::Info::PPM", "1.38"],
    ["Image::Info::SVG", "2.02"],
    ["Image::Info::TIFF", "0.04"],
    #["Image::Info::WBMP", "1.38"],
    #["Image::Info::XBM", "1.38"],
    #["Image::Info::XPM", "1.38"],
    ["Image::TIFF", "1.09"],
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
