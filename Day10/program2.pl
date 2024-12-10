#!/usr/bin/perl -w

use strict;

my $fd;

open($fd, "<", "input2.txt") or die "Could not open input for reading";

my $map = [];

while (my $line = <$fd>)
{
    chomp $line;
    push @{$map}, [];

    foreach my $char (split //, $line)
    {
        push @{$map->[-1]}, { value => $char, visited => 0 };
    }
}

close $fd;

# print_map($map);
my $score = get_total_trailhead_score($map);

print "Total trailhead score: $score\n";

sub print_map
{
    my $map = shift;

    for (my $y = 0; $y < @{$map}; $y++)
    {
        for (my $x = 0; $x < @{$map->[$y]}; $x++)
        {
            print $map->[$y]->[$x]->{value};
        }

        print "\n";
    }
}

sub print_visit_map
{
    my $map = shift;
    my $trail = shift;

    for (my $y = 0; $y < @{$map}; $y++)
    {
        for (my $x = 0; $x < @{$map->[$y]}; $x++)
        {
            if ($map->[$y]->[$x]->{visited} != $trail)
            {
                print ".";
            }
            else
            {
                print "#";
            }
        }

        print "\n";
    }
}

sub get_total_trailhead_score
{
    my $map = shift;

    my $total = 0;
    my $trail = 0;

    for (my $y = 0; $y < @{$map}; $y++)
    {
        for (my $x = 0; $x < @{$map->[$y]}; $x++)
        {
            if ($map->[$y]->[$x]->{value} == 0)
            {
                $trail++;
                # print "Trail $trail start at $x, $y\n";
                my $score = get_trailhead_score($map, $x, $y, $trail);
                # print "Trailhead score: $score\n";
                $total += $score;

                # print_visit_map($map, $trail);
            }
        }
    }

    return $total;
}

sub get_trailhead_score
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $trail = shift;

    my $next_value = $map->[$y]->[$x]->{value} + 1;

    my $score = 0;

    $map->[$y]->[$x]->{visited} = $trail;

    if ($map->[$y]->[$x]->{value} == 9)
    {
        return 1;
    }

    for (my $j = -1; $j <= 1; $j++)
    {
        for (my $i = -1; $i <= 1; $i++)
        {
            if (($i == 0 && $j == 0) || ($i != 0 && $j != 0))
            {
                next;
            }

            my $next_x = $x + $i;
            my $next_y = $y + $j;

            if ($next_x >= 0 && $next_x < @{$map->[$y]} && $next_y >= 0 && $next_y < @{$map})
            {
                if ($map->[$next_y]->[$next_x]->{value} == $next_value)
                {
                    # print "$x, $y -> $next_x, $next_y\n";
                    $score += get_trailhead_score($map, $next_x, $next_y, $trail);
                }
            }
        }
    }

    return $score;
}
