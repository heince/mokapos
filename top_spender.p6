#!/usr/bin/env perl6 
#===============================================================================
#
#         FILE: top_spender.p6
#
#        USAGE: ./top_spender.p6 [transaction csv file path] 
#
#  DESCRIPTION: parse customer list csv, get top spending customer of the year
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

my @customers;
my $count = 1;
my $max-result = 50;
my $max-line = 2000;

while my %data = %($parser.get_line()) {
    next unless %data{"Phone"} ~~ /^\+\d+/; #member always have mobile number
    next if %data{"Name"} ~~ ''; #member always have a name
    next if %data{"Email"} ~~ ''; #member always have an email
    next if %data{"Amount This Year"} == 0; #exclude non spending member

    my $name = %data{"Name"};
    my $email = %data{"Email"};
    my $phone = %data{"Phone"};
    my $amount-this-year = %data{"Amount This Year"};
    my $customer-since = %data{"Customer Since"};
    my $last-visit = %data{"Last Visit"};

    push @customers, %( name => $name, 
                        email => $email, 
                        phone => $phone, 
                        amount-this-year => $amount-this-year,
                        customer-since =>  $customer-since,
                        last-visit => $last-visit);
    last if $count > $max-line;

    $count++;
}

$fh.close();

$count = 1; #reset count
for reverse @customers.sort: { .<amount-this-year>.Int } {
    #say qq|"{.<name>}"| ~ ' ' ~ .<email> ~ ' ' ~ .<phone> ~ ' ' ~ .<amount-this-year>;
    .say;
    last if $count > $max-result;
    $count++;
}