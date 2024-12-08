#!/usr/bin/perl -w

use strict;

my $config = {
    width => 50,
    height => 50,
    antennas => {
        a => [[10, 10], [16,16]]
    }
};

for (my $y = 0; $y < $config->{height}; $y++)
{
    for (my $x = 0; $x < $config->{width}; $x++)
    {
        my $found = 0;

        foreach my $antenna (keys %{$config->{antennas}})
        {
            foreach my $pos (@{$config->{antennas}->{$antenna}})
            {
                if ($pos->[0] == $x && $pos->[1] == $y)
                {
                    die "Antenna $antenna is placed on top of another antenna\n" if $found;

                    $found = 1;
                    print $antenna;
                    last;
                }
            }
        }
        if (not $found)
        {
            print ".";
            next;
        }
    }
    print "\n";
}