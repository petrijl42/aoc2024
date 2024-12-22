#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $filename = "input2.txt";

    my $numbers = read_input_numbers($filename);
    my $secret_numbers_sum = get_secet_numbers_sum($numbers, 2000);

    print "Secret numbers sum: $secret_numbers_sum\n";
}

sub read_input_numbers
{
    my $filename = shift;

    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my @numbers;

    while (my $line = <$fd>)
    {
        chomp $line;
        push @numbers, $line;
    }

    close $fd;

    return \@numbers;
}

sub get_secet_numbers_sum
{
    my $numbers = shift;
    my $iterations = shift;

    my $sum = 0;

    foreach my $number (@$numbers)
    {
        $sum += iterate_secret_number($number, $iterations);
    }

    return $sum;
}

sub iterate_secret_number
{
    my $number = shift;
    my $iterations = shift;

    for (my $i = 0; $i < $iterations; $i++)
    {
        $number = get_next_secret_number($number);
    }

    return $number;
}

sub get_next_secret_number
{
    my $number = shift;

    my $next;

    $next = $number * 64;
    $next = $next ^ $number;
    $number = $next % 16777216;

    $next = $number / 32;
    $next = $next ^ $number;
    $number = $next % 16777216;

    $next = $number * 2048;
    $next = $next ^ $number;
    $number = $next % 16777216;

    return $number;
}
