# tests for perl-timedate-2.30-0 (this is a generated file)
print("===== testing package: perl-timedate-2.30-0 =====\n");
my $expected_version = "2.3";
print("import: Date::Parse\n");
use Date::Parse;

if (defined Date::Parse->VERSION) {
	my $given_version = Date::Parse->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Date::Parse->VERSION . '
');

}
my $expected_version = "2.24";
print("import: Date::Format\n");
use Date::Format;

if (defined Date::Format->VERSION) {
	my $given_version = Date::Format->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Date::Format->VERSION . '
');

}
my $expected_version = "1.1";
print("import: Date::Language\n");
use Date::Language;

if (defined Date::Language->VERSION) {
	my $given_version = Date::Language->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Date::Language->VERSION . '
');

}
my $expected_version = "2.24";
print("import: Time::Zone\n");
use Time::Zone;

if (defined Time::Zone->VERSION) {
	my $given_version = Time::Zone->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Time::Zone->VERSION . '
');

}
# no run_test.pl exists for this package

print("===== perl-timedate-2.30-0 OK =====\n");
