#!/usr/bin/perl -w

use strict;

use Storable;

my $fd;

open ($fd, '<', "input2.txt") || die 'Could not open input for reading';

my @map;
my @dir_map;

while (my $line = <$fd>)
{
    $line =~ s/\n//;

    my @row = split //, $line;

    push @map, \@row;
}

close $fd;

my $direction = [0, -1];
my ($x, $y) = find_start(\@map);

my $positions = walk_map(\@map, $x, $y, $direction, \@dir_map);

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
    my $dir_map = shift;

    my $max_iterations = 1000000;
    my $positions = 0;

    update_map($map, $x, $y, $direction, $dir_map);

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
            $direction = turn($direction);
        }
        else
        {
            if ($map->[$new_y]->[$new_x] eq '.')
            {
                my $pred_map = Storable::dclone($map);
                my $pred_dir_map = Storable::dclone($dir_map);

                $pred_map->[$new_y]->[$new_x] = '#';

                if (check_loop($pred_map, $x, $y, $direction, $pred_dir_map))
                {
                    $positions++;
                }
            }

            $x = $new_x;
            $y = $new_y;

            update_map($map, $x, $y, $direction, $dir_map);
        }
    }

    return $positions;
}

sub check_loop
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $direction = shift;
    my $dir_map = shift;

    my $max_iterations = 1000000;
    my $positions = 0;

    for (my $i = 0; $i < $max_iterations; $i++)
    {
        my $new_x = $x + $direction->[0];
        my $new_y = $y + $direction->[1];

        if ($new_x < 0 || $new_x >= int(@{$map->[0]}) || $new_y < 0 || $new_y >= int(@{$map}))
        {
            return 0;
        }
        if ($map->[$new_y]->[$new_x] eq '#')
        {
            $direction = turn($direction);
        }
        else
        {
            $x = $new_x;
            $y = $new_y;

            if ($map->[$y]->[$x] eq 'X')
            {
                foreach my $prev_dir (@{$dir_map->[$y]->[$x]})
                {
                    if ($prev_dir->[0] == $direction->[0] &&
                        $prev_dir->[1] == $direction->[1])
                    {
                        return 1;
                    }
                }
            }

            update_map($map, $x, $y, $direction, $dir_map);
        }
    }

    print "Max iterations reached\n";

    return 0;
}

sub update_map
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $direction = shift;
    my $dir_map = shift;

    $map->[$y]->[$x] = 'X';
    if (not defined $dir_map->[$y]->[$x])
    {
        $dir_map->[$y]->[$x] = ();
    }
    push @{$dir_map->[$y]->[$x]}, $direction;
}

sub turn
{
    my $direction = shift;
    my $x = $direction->[0];
    my $y = $direction->[1];

    my $new_dir = ();
    $new_dir->[0] = $y * -1;
    $new_dir->[1] = $x;

    return $new_dir;
}

sub print_map
{
    my $map = shift;

    print "Map:\n";
    foreach my $row (@{$map})
    {
        print join("", @{$row}) . "\n";
    }
}
