#!/usr/bin/perl -w

use strict;

my $fd;

open ($fd, '<', 'input2.txt') || die "Could not open input for reading";

my $safe = 0;

while (my $line = <$fd>)
{
    $line =~ s/\n//;
    my @reports = split / /, $line;

    my $prev;
    my $direction;
    
    my $is_safe = 1;

    print join(" ", @reports) .": ";
    foreach my $report (@reports)
    {
        my $movement;
        die "Invalid data" unless $report =~ /^\d+$/;

        if (defined $prev)
        {
            $movement = get_direction($prev, $report);

            if (defined $direction)
            {
                if ((defined $movement) && ($direction ne $movement))
                {
                    $is_safe = 0;
                    print "Direction $direction vs $movement ";
                } 
            }
            else
            {
                $direction = $movement;
            }

            if (abs($report - $prev) > 3)
            {
                $is_safe = 0;
                print "Movement of " . abs($report - $prev) . " ";
            }

            print $report - $prev . " ";

            if ($report - $prev == 0)
            {
                $is_safe = 0;
                print "No movement ";
            }
        }

        $prev = $report;

        last unless $is_safe == 1;
    }
    if ($is_safe == 1)
    {
        $safe++;
        print "Safe ($safe)\n";
    }
    else
    {
        print "Not safe\n";
    }
}
close $fd;

print "Safe reports: $safe\n";

sub get_direction
{
    my $first = shift;
    my $second = shift;

    return 'down' if ($first > $second);
    return 'up' if ($second > $first);
    return undef;
}