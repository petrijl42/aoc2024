#!/usr/bin/perl -w

use strict;

my $fd;

open ($fd, '<', "input2.txt") || die 'Could not open input for reading';

my @map;

while (my $line = <$fd>)
{
    $line =~ s/\n//;

    my @row = split //, $line;

    push @map, \@row;
}

close $fd;

my $direction = [0, -1];
my ($x, $y) = find_start(\@map);
walk_map(\@map, $x, $y, $direction);

# print "Map:\n";
# foreach my $row (@map)
# {
#     print join("", @{$row}) . "\n";
# }

my $positions = count_positions(\@map);

print "Positions: $positions\n";

sub find_start
{
    my $map = shift;

    for (my $i = 0; $i < int(@{$map}); $i++)
    {
        for (my $j = 0; $j < int(@{$map->[$i]}); $j++)
        {
            if ($map->[$i]->[$j] eq '^')
            {
                return ($j, $i);
            }
        }
    }
}

sub walk_map
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $direction = shift;

    my $max_iterations = 1000000;

    $map->[$y]->[$x] = 'X';

    for (my $i = 0; $i < $max_iterations; $i++)
    {
        my $new_x = $x + $direction->[0];
        my $new_y = $y + $direction->[1];

        if ($new_x < 0 || $new_x >= int(@{$map->[0]}) || $new_y < 0 || $new_y >= int(@{$map}))
        {
            last;
        }
        if ($map->[$new_y]->[$new_x] eq '#')
        {
            turn($direction);
        }
        else
        {
            $x = $new_x;
            $y = $new_y;

            $map->[$y]->[$x] = 'X';
        }
    }
}

sub turn
{
    my $direction = shift;
    my $x = $direction->[0];
    my $y = $direction->[1];

    $direction->[0] = $y * -1;
    $direction->[1] = $x;
}

sub count_positions
{
    my $map = shift;

    my $positions = 0;

    for (my $i = 0; $i < int(@{$map}); $i++)
    {
        for (my $j = 0; $j < int(@{$map->[$i]}); $j++)
        {
            if ($map->[$i]->[$j] eq 'X')
            {
                $positions++;
            }
        }
    }

    return $positions;
}