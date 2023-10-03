my $expected_version = "0.013";
print("import: Parallel::Runner\n");
use Parallel::Runner;

if (defined Parallel::Runner->VERSION) {
	my $given_version = Parallel::Runner->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Parallel::Runner->VERSION . '
');

}
