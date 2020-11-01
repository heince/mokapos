use v5.16;
use Text::CSV qw/csv/;

usage() unless $ARGV[0];
usage() unless $ARGV[1];
usage() unless $ARGV[2];
usage() unless $ARGV[3];

my $branch = lc($ARGV[0]);
my $outlet;
my $sortby = lc($ARGV[1]);
usage() unless $sortby eq 'sales';

my $tx_csv = $ARGV[2];
die "transaction csv file not found\n" unless -s $tx_csv;

my $cust_csv = $ARGV[3];
die "customer csv file not found\n" unless -s $cust_csv;

if ($branch eq 'pik') {
	$outlet = 'IN TEA Pik';
}
elsif ($branch eq 'gancit') {
	$outlet = 'IN TEA Gancit';
}
else {
	usage();
}

my $cust = csv (in => $cust_csv, key => 'Phone');

my $tx = {};
my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1 });
open my $fh, "<:encoding(utf8)", $tx_csv or die "$!\n";
while (my $row = $csv->getline($fh)) {
	$row->[15] or next;
	next if $row->[15] =~ /Customer/;
	next if $row->[0] ne $outlet;
	$tx->{$row->[15]}->{total} += $row->[6];
}
close $fh;

open my $fhw, ">:encoding(utf8)", "top_cust_sales.csv" or die "top_cust_sales.csv: $!";
my $header = [ 'Phone', 
								'Name',
								'Email',
								'Birthday',
								'Sex', 
								'Customer Since', 
								'Last Visit',
								'Total # of orders',
								'Member Since',
								'Current Point Balance',
								'Total' ];
$csv->say($fhw, $header);
for my $phone (sort { $tx->{$b}->{total} <=> $tx->{$a}->{total} } keys %{$tx}) {
	my @lines = (
		$phone,
		$cust->{$phone}->{Name},
		$cust->{$phone}->{Email},
		$cust->{$phone}->{Birthday},
		$cust->{$phone}->{Sex},
		$cust->{$phone}->{'Customer Since'},
		$cust->{$phone}->{'Last Visit'},
		$cust->{$phone}->{'Total # of orders'},
		$cust->{$phone}->{'Member Since'},
		$cust->{$phone}->{'Current Point Balance'},
		$tx->{$phone}->{total}
	);
	$csv->say($fhw, \@lines);
}

close $fhw or die "$!\n";

sub usage() {
	say "$0 [branch] [sort by] [transaction csv file path] [customer list csv file path]";
	say "supported branch is pik or gancit";
	say "sort by sales";
	exit 1;
}
