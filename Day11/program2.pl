#!/usr/bin/perl -w

use strict;
use Math::BigInt lib => 'GMP';

my $fd;

open($fd, "<", "input2.txt") or die "Could not open input for reading";
my $iterations = 75;

my $line = <$fd> || die "Could not read from input";


close($fd);

chomp $line;
my $stones =  [];

foreach my $number (split / /, $line)
{
    push @$stones, Math::BigInt->new($number);
}

my $count = 0;
my $cache = {};

foreach my $stone (@$stones)
{
    $count += stone_count($stone, $iterations, $cache);
    # print "Count $count\n";
}

print "Result: $count\n";

sub stone_count
{
    my $stone = shift;
    my $iterations = shift;
    my $cache = shift;

    $iterations--;

    if ($iterations < 0)
    {
        # print $stone->bstr() . " ";
        return 1;
    }

    if ($stone->is_zero())
    {
        return stone_count(Math::BigInt->new(1), $iterations, $cache);
    }

    my $string = $stone->bstr();
    my $length = length($string);

    if ($length % 2 == 0)
    {
        if (not defined $cache->{$string}->{$iterations})
        {
            my $half = $length / 2;

            my $count = stone_count(Math::BigInt->new(substr($string, 0, $half)), $iterations, $cache) +
                        stone_count(Math::BigInt->new(substr($string, $half, $half)), $iterations, $cache);

            $cache->{$string}->{$iterations} = $count;
        }

        return $cache->{$string}->{$iterations};
    }

    return stone_count($stone->bmul(2024), $iterations, $cache);
}
