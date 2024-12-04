#!/usr/bin/perl -w

use strict;

my $fd;

open ($fd, '<', 'input1.txt') || die "Could not open input for reading";

my $sum = 0;
while (my $line = <$fd>)
{
    my @matches = $line =~ /(mul\(\d+,\d+\))/g;

    foreach my $match (@matches)
    {
        my ($a, $b) = $match =~ /^mul\((\d+),(\d+)\)$/;

        #print "$a * $b\n";

        $sum += $a * $b;
    }
}

print "Result: $sum\n";
