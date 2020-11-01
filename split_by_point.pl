use v5.16;
use Text::CSV qw/csv/;

usage() unless $ARGV[0];

my $tx_csv = $ARGV[0];
die "transaction csv file not found\n" unless -s $tx_csv;

my $tx = csv (in => $tx_csv, key => 'Phone');
my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1 });
open my $fh10, ">:encoding(utf8)", "10_point.csv" or die "$!\n";
open my $fh25, ">:encoding(utf8)", "25_point.csv" or die "$!\n";
open my $fh50, ">:encoding(utf8)", "50_point.csv" or die "$!\n";

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
$csv->say($fh10, $header);
$csv->say($fh25, $header);
$csv->say($fh50, $header);

for my $phone ( keys %{$tx} ) {
	if ( $tx->{$phone}->{'Current Point Balance'} >= 10 and $tx->{$phone}->{'Current Point Balance'}	< 25 ) {
		$csv->say( $fh10, get_lines($phone) );
	}
	elsif ( $tx->{$phone}->{'Current Point Balance'} >= 25 and $tx->{$phone}->{'Current Point Balance'}  < 50 ) {
		$csv->say( $fh25, get_lines($phone) );
	}
	elsif ( $tx->{$phone}->{'Current Point Balance'} >= 50 ) {
		$csv->say( $fh50, get_lines($phone) );
	}
}

close $fh10 or die "$!\n";
close $fh25 or die "$!\n";
close $fh50 or die "$!\n";

sub get_lines() {
	my $phone = shift;
	
	my @lines = (
			$phone,
			$tx->{$phone}->{Name},
			$tx->{$phone}->{Email},
			$tx->{$phone}->{Birthday},
			$tx->{$phone}->{Sex},
			$tx->{$phone}->{'Customer Since'},
			$tx->{$phone}->{'Last Visit'},
			$tx->{$phone}->{'Total # of orders'},
			$tx->{$phone}->{'Member Since'},
			$tx->{$phone}->{'Current Point Balance'},
			$tx->{$phone}->{Total}
	);

	return \@lines;
}

sub usage() {
	say "$0 [branch] [sort by] [transaction csv file path] [customer list csv file path]";
	say "supported branch is pik or gancit";
	say "sort by sales";
	exit 1;
}
