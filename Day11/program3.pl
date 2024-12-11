#!/usr/bin/perl -w

use strict;

my $fd;

open($fd, "<", "input2.txt") or die "Could not open input for reading";
my $iterations = 75;
# my $max = 0;

my $line = <$fd> || die "Could not read from input";


close($fd);

chomp $line;
my $stones =  [];

foreach my $number (split / /, $line)
{
    push @$stones, $number;
}

my $count = 0;
my $cache = {};

foreach my $stone (@$stones)
{
    $count += stone_count($stone, $iterations, $cache);
    # print "Count $count\n";
}

print "Result: $count\n";
# print "Max: " . $max ."\n";

sub stone_count
{
    my $stone = shift;
    my $iterations = shift;
    my $cache = shift;

    $iterations--;

    # if ($stone > $max)
    # {
    #     $max = $stone;
    # }

    if ($iterations < 0)
    {
        return 1;
    }

    if ($stone == 0)
    {
        return stone_count(1, $iterations, $cache);
    }

    my $length = length($stone);

    if ($length % 2 == 0)
    {
        if (not defined $cache->{$stone}->{$iterations})
        {
            my $half = $length / 2;

            my $count = stone_count(int(substr($stone, 0, $half)), $iterations, $cache) +
                        stone_count(int(substr($stone, $half, $half)), $iterations, $cache);

            $cache->{$stone}->{$iterations} = $count;
        }

        return $cache->{$stone}->{$iterations};
    }

    return stone_count($stone * 2024, $iterations, $cache);
}
