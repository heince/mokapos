#!/usr/bin/env perl6 
#===============================================================================
#
#         FILE: get_winner.p6
#
#        USAGE: ./get_winner.p6 [transaction csv file path] 
#
#  DESCRIPTION: parse exported moka tx csv, then pick winner for qualified customer
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Heince Kurniawan
#       EMAIL : cs.inteacafe@gmail.com
# ORGANIZATION: IN
#      VERSION: 1.0
#      CREATED: 07/25/18 00:54:39
#     REVISION: ---
#===============================================================================

use v6;
use CSV::Parser;

my $csv = @*ARGS[0];
die "empty csv\n" unless $csv.IO.s > 0;

my $fh  = open $csv, :r;
my $parser = CSV::Parser.new( file_handle => $fh, contains_header_row => True );

my @candidates;
my Int $winner = 2;
my Int $min_purchase = 100000;
my Str $outlet = 'IN TEA Gancit';

while my %data = %($parser.get_line()) {
    next unless %data{"Outlet"} eq $outlet;
    next unless %data{"Customer Phone"} ~~ /^\+\d+/; #member always have mobile number

    my $str = "Mobile: " ~ %data{"Customer Phone"};
    $str ~= "\n\tDate: " ~ %data{"Date"};
    $str ~= "\n\tTime: " ~ %data{"Time"};
    $str ~= "\n\tItems: " ~ %data{"Items"};

    push @candidates, $str if %data{"Net Sales"} >= $min_purchase;
}

$fh.close();

if @candidates.elems > 0
{
    say "Total Candidates: " ~ @candidates.elems;
    say "Winners:";
    say @candidates.pick($winner).join("\n");
}
else
{
    say "no winner";
}
