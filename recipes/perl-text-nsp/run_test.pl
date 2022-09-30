#!/usr/bin/env perl

my @items = (
    ["Text::NSP", "1.31"],
    ["Text::NSP::Measures", "0.97"],
    ["Text::NSP::Measures::2D", "0.97"],
    ["Text::NSP::Measures::2D::CHI", "1.03"],
    ["Text::NSP::Measures::2D::CHI::phi", "0.97"],
    ["Text::NSP::Measures::2D::CHI::tscore", "0.97"],
    ["Text::NSP::Measures::2D::CHI::x2", "0.97"],
    ["Text::NSP::Measures::2D::Dice", "0.97"],
    ["Text::NSP::Measures::2D::Dice::dice", "0.97"],
    ["Text::NSP::Measures::2D::Dice::jaccard", "0.97"],
    ["Text::NSP::Measures::2D::Fisher", "0.97"],
    ["Text::NSP::Measures::2D::Fisher2", "0.97"],
    ["Text::NSP::Measures::2D::Fisher2::left", "0.97"],
    ["Text::NSP::Measures::2D::Fisher2::right", "0.97"],
    ["Text::NSP::Measures::2D::Fisher2::twotailed", "0.97"],
    ["Text::NSP::Measures::2D::Fisher::left", "0.97"],
    ["Text::NSP::Measures::2D::Fisher::right", "0.97"],
    ["Text::NSP::Measures::2D::Fisher::twotailed", "0.97"],
    ["Text::NSP::Measures::2D::MI", "1.03"],
    ["Text::NSP::Measures::2D::MI::ll", "0.97"],
    ["Text::NSP::Measures::2D::MI::pmi", "0.97"],
    ["Text::NSP::Measures::2D::MI::ps", "0.97"],
    ["Text::NSP::Measures::2D::MI::tmi", "0.97"],
    ["Text::NSP::Measures::2D::odds", "0.97"],
    ["Text::NSP::Measures::3D", "0.97"],
    ["Text::NSP::Measures::3D::MI", "1.03"],
    ["Text::NSP::Measures::3D::MI::ll", "0.97"],
    ["Text::NSP::Measures::3D::MI::pmi", "0.97"],
    ["Text::NSP::Measures::3D::MI::ps", "0.97"],
    ["Text::NSP::Measures::3D::MI::tmi", "0.97"],
    ["Text::NSP::Measures::4D", "0.97"],
    ["Text::NSP::Measures::4D::MI", "1.03"],
    ["Text::NSP::Measures::4D::MI::ll", "0.97"],
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
