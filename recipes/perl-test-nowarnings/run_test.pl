# tests for perl-test-nowarnings-1.04-0 (this is a generated file)
print("===== testing package: perl-test-nowarnings-1.04-0 =====\n");
my $expected_version = "1.04";
print("import: Test::NoWarnings\n");
require Test::NoWarnings;

if (defined Test::NoWarnings->VERSION) {
	my $given_version = Test::NoWarnings->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Test::NoWarnings->VERSION . '
');

}
# no run_test.pl exists for this package

print("===== perl-test-nowarnings-1.04-0 OK =====\n");
