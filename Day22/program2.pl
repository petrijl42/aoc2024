#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $filename = "input2.txt";

    my $numbers = read_input_numbers($filename);
    my $count = get_banana_count($numbers, 2000);

    print "Banana count: $count\n";
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

sub get_banana_count
{
    my $numbers = shift;
    my $iterations = shift;

    my $max = 0;
    my %sequences;

    for (my $i = 0; $i < scalar(@$numbers); $i++)
    {
        # print "Monkey $i\n";

        my $count = iterate_monkey($numbers->[$i], $iterations, \%sequences, $i);

        if ($count > $max)
        {
            $max = $count;
        }
    }

    return $max;
}

sub iterate_monkey
{
    my $number = shift;
    my $iterations = shift;
    my $sequences = shift;
    my $monkey = shift;

    my @numbers;
    my $max = 0;

    for (my $i = 0; $i < $iterations; $i++)
    {
        # print "Iteration $i: $number\n";

        my $bananas = $number % 10;

        push @numbers, $bananas;
        if (scalar(@numbers) > 4)
        {
            shift @numbers if scalar(@numbers) > 5;

            my $sequence = get_sequence(\@numbers);

            if ((not defined $sequences->{$sequence}->{monkey}) || $sequences->{$sequence}->{monkey} != $monkey)
            {
                $sequences->{$sequence}->{bananas} += $bananas;
                $sequences->{$sequence}->{monkey} = $monkey;

                if ($sequences->{$sequence}->{bananas} > $max)
                {
                    $max = $sequences->{$sequence}->{bananas};
                }
            }
        }

        $number = get_next_secret_number($number);
    }

    return $max;
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

sub get_sequence
{
    my $numbers = shift;
    my @sequence;

    for (my $i = 0; $i < (scalar(@$numbers) - 1); $i++)
    {
        push @sequence, ($numbers->[$i+1]) - ($numbers->[$i]);
    }

    return join(",", @sequence);
}
