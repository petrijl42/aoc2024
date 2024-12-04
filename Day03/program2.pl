#!/usr/bin/perl -w

use strict;

my $fd;

open ($fd, '<', 'input2.txt') || die "Could not open input for reading";

my $sum = 0;
my $disabled = 0;

while (my $line = <$fd>)
{
    my @matches = $line =~ /(mul\(\d+,\d+\)|do\(\)|don't\(\))/g;

    foreach my $match (@matches)
    {
        if ($match =~ /^mul\(/)
        {
            if (!$disabled)
            {
                my ($a, $b) = $match =~ /^mul\((\d+),(\d+)\)$/;

                #print "$a * $b\n";

                $sum += $a * $b;
            }
        }
        elsif ($match =~ /^do\(/)
        {
            $disabled = 0;
        }
        elsif ($match =~ /don't\(/)
        {
            $disabled = 1;
        }
    }
}

print "Result: $sum\n";
