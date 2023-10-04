my $expected_version = "0.013";
print("import: Child\n");
use Child;

if (defined Child->VERSION) {
	my $given_version = Child->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Child->VERSION . '
');

}
