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

close($fd);

my $value = check_map($map);

print "Value: $value\n";

sub create_empty_map
{
    my $map = shift;
    my $copy = [];

    foreach my $row (@{$map})
    {
        my $line = [];
        my $length = int(@{$row});

        foreach my $plot (split(//, "." x $length))
        {
            push @{$line}, { value => $plot };
        }

        push @{$copy}, $line;
    }

    return $copy;
}

sub count_fences
{
    my $map = shift;
    my $value = shift;

    my $count = 0;

    for (my $x = 0; $x < scalar @{$map}; $x++)
    {
        for (my $y = 0; $y < scalar @{$map->[$x]}; $y++)
        {
            my $plot = $map->[$x][$y];
            next unless $plot->{value} eq $value;

            my @directions = ([0, 1], [1, 0], [0, -1], [-1, 0]);

            foreach my $direction (@directions)
            {
                if ($plot->{fences}->{$direction->[0]}->{$direction->[1]})
                {
                    my $fence_x = $x + $direction->[0];
                    my $fence_y = $y + $direction->[1];
                    my $fence_plot = get_map_value($map, $fence_x, $fence_y);

                    my $rotated = rotate($direction);

                    my $neighbour_x = $x + $rotated->[0];
                    my $neighbour_y = $y + $rotated->[1];

                    my $neighbour_plot = get_map_value($map, $neighbour_x, $neighbour_y);

                    if  ((not defined $neighbour_plot) || ($neighbour_plot->{value} ne $value))
                    {
                        $count++;
                    }
                    elsif (not $neighbour_plot->{fences}->{$direction->[0]}->{$direction->[1]})
                    {
                        $count++;
                    }
                }
            }
        }
    }

    return $count;
}

sub rotate
{
    my $direction = shift;
    my $rotated = [];

    my $x = $direction->[0];
    my $y = $direction->[1];

    $rotated->[0] = $y;
    $rotated->[1] = -$x;

    return $rotated;
}

sub get_map_value
{
    my $map = shift;
    my $x = shift;
    my $y = shift;

    if ($x >= 0 && $x < scalar @{$map} && $y >= 0 && $y < scalar @{$map->[$x]})
    {
        return $map->[$x][$y];
    }

    return undef;
}

sub check_map
{
    my $map = shift;
    my $value = 0;

    my $new_neighbours;
    my @check_list = ({ x => 0, y => 0, value => $map->[0][0]->{value} });

    foreach my $item (@check_list)
    {
        $new_neighbours = 0;

        my $x = $item->{x};
        my $y = $item->{y};

        next if $map->[$x][$y]->{visited};

        my $area_map = create_empty_map($map);
        my $info = get_area_info($map, $item->{x}, $item->{y}, $area_map);

        foreach my $neighbour (@{$info->{neighbours}})
        {
            push @check_list, $neighbour;
        }

        my $fences = count_fences($area_map, $map->[$x][$y]->{value});
        $value += $info->{area} * $fences;
    }

    return $value;
}


sub get_area_info
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $area_map = shift;

    my $plots = [{ x => $x, y => $y, value => $map->[$x][$y]->{value} }];
    my $neighbours = [];
    my $area = 0;
    my $perimeter = 0;

    foreach my $plot (@{$plots})
    {
        my $info = get_plot_info($map, $plot, $area_map);
        $area += $info->{area};
        $perimeter += $info->{perimeter};

        foreach my $neighbour (@{$info->{neighbours}})
        {
            push @{$neighbours}, $neighbour;
        }
        foreach my $plot (@{$info->{plots}})
        {
            push @{$plots}, $plot;
        }
    }

    return { area => $area, perimeter => $perimeter, neighbours => $neighbours };
}

sub get_plot_info
{
    my $map = shift;
    my $plot = shift;
    my $area_map = shift;

    my $x = $plot->{x};
    my $y = $plot->{y};

    my @directions = ([0, 1], [1, 0], [0, -1], [-1, 0]);
    my $neighbours = [];
    my $plots = [];
    my $area = 0;
    my $perimeter = 0;

    unless ($map->[$x]->[$y]->{visited})
    {
        my $value = $map->[$x][$y]->{value};
        $area_map->[$x][$y]->{value} = $map->[$x][$y]->{value};
        $map->[$x][$y]->{visited} = 1;
        $area++;

        for (my $i = 0; $i < scalar @directions; $i++)
        {
            my $new_x = $x + $directions[$i][0];
            my $new_y = $y + $directions[$i][1];

            if ($new_x < 0 || $new_x >= scalar @{$map} || $new_y < 0 || $new_y >= scalar @{$map->[$new_x]})
            {
                $area_map->[$x][$y]->{fences}->{$directions[$i][0]}->{$directions[$i][1]} = 1;
                $perimeter++;
                next;
            }

            if ($map->[$new_x][$new_y]->{value} eq $map->[$x][$y]->{value})
            {
                next if ($map->[$new_x][$new_y]->{visited});

                push @{$plots}, { x => $new_x, y => $new_y, value => $map->[$new_x][$new_y]->{value} };
            }
            else
            {
                $perimeter++;
                $area_map->[$x][$y]->{fences}->{$directions[$i][0]}->{$directions[$i][1]} = 1;
                unless ($map->[$new_x][$new_y]->{visited})
                {
                    push @{$neighbours}, { x => $new_x, y => $new_y, value => $map->[$new_x][$new_y]->{value}};
                }
            }
        }

    }
    return { area => $area, perimeter => $perimeter, neighbours => $neighbours, plots => $plots };
}