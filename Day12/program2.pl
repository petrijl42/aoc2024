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

sub print_map
{
    my $map = shift;

    for (my $x = 0; $x < scalar @{$map}; $x++)
    {
        for (my $y = 0; $y < scalar @{$map->[$x]}; $y++)
        {
            print $map->[$x][$y]->{value};
        }
        print "\n";
    }
}

my $value = check_map($map);

print "Value: $value\n";

sub create_empty_map
{
    my $map = shift;
    my $copy = [];


    my $padding = [];
    foreach my $plot (split //, " " x (2 + scalar @{$map->[0]}))
    {
        push @{$padding}, { value => $plot};
    }
    push @{$copy}, $padding;

    foreach my $row (@{$map})
    {
        my $line = [];
        foreach my $plot ((' ', split(//, "." x int(@{$row})), ' '))
        {
            push @{$line}, { value => $plot };
        }

        push @{$copy}, $line;
    }

    $padding = [];
    foreach my $plot (split //, " " x (2 + scalar @{$map->[0]}))
    {
        push @{$padding}, { value => $plot};
    }
    push @{$copy}, $padding;

    return $copy;
}

sub count_fence_starts
{
    my $map = shift;
    my $value = shift;

    my $count = 0;

    for (my $x = 0; $x < scalar @{$map}; $x++)
    {
        for (my $y = 0; $y < scalar @{$map->[$x]}; $y++)
        {
            my $plot = $map->[$x][$y];
            # print "Value: $plot->{value}\n";
            next unless $plot->{value} eq $value;

            my @directions = ([0, 1], [1, 0], [0, -1], [-1, 0]);

            # foreach my $i (keys %{$plot->{fences}})
            # {
            #     foreach my $j (keys %{$plot->{fences}->{$i}})
            #     {
            #         print "Fence: $i, $j\n";
            #     }
            # }

            foreach my $direction (@directions)
            {
                # print "Checking: $x, $y, $direction->[0], $direction->[1]\n";

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
                        # print "No neighbour: $x, $y, $rotated->[0], $rotated->[1], $neighbour_x, $neighbour_y\n";
                        $count++;
                    }
                    elsif (not $neighbour_plot->{fences}->{$direction->[0]}->{$direction->[1]})
                    {
                        # print "$value $neighbour_plot->{value}\n";
                        # print "No neigbour fence: $x, $y, $direction->[0], $direction->[1], $neighbour_x, $neighbour_y\n";
                        $count++;
                    }
                    else
                    {
                        # print "Fence: $x, $y, $direction->[0], $direction->[1], $neighbour_x, $neighbour_y\n";
                    }
                }
                else
                {
                    # print "No fence: $x, $y, $direction->[0], $direction->[1]\n";
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

        # print_map($area_map);
        # print "\n";

        foreach my $neighbour (@{$info->{neighbours}})
        {
            push @check_list, $neighbour;
        }

        my $fences = count_fence_starts($area_map, $map->[$x][$y]->{value});
        $value += $info->{area} * $fences;

        # print "Value: " . $map->[$x][$y]->{value} . "\n";
        # print "Area: " . $info->{area} . "\n";
        # print "Fences: " . $fences . "\n";
        # print "Perimeter: " . $info->{perimeter} . "\n";
        # print "\n";
        # print_info($info);
    }

    return $value;
}

sub print_info
{
    my $info = shift;

    print "Area: " . $info->{area} . "\n";
    print "Perimeter: " . $info->{perimeter} . "\n";
    foreach my $neighbour (@{$info->{neighbours}})
    {
        print "Neighbour: " . $neighbour->{x} . " " . $neighbour->{y} . " " . $neighbour->{value} . "\n";
    }
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

    # print "Value: " . $map->[$x][$y]->{value} . "\n";
    # print "Area: $area\n";
    # print "Perimeter: $perimeter\n";

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
        $area_map->[$x+1][$y+1]->{value} = $map->[$x][$y]->{value};
        $map->[$x][$y]->{visited} = 1;
        $area++;

        for (my $i = 0; $i < scalar @directions; $i++)
        {
            my $new_x = $x + $directions[$i][0];
            my $new_y = $y + $directions[$i][1];

            if ($new_x < 0 || $new_x >= scalar @{$map} || $new_y < 0 || $new_y >= scalar @{$map->[$new_x]})
            {
                $area_map->[$new_x + 1][$new_y + 1]->{value} = '#';
                $area_map->[$x+1][$y+1]->{fences}->{$directions[$i][0]}->{$directions[$i][1]} = 1;
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
                $area_map->[$new_x + 1][$new_y + 1]->{value} = '#';
                $area_map->[$x+1][$y+1]->{fences}->{$directions[$i][0]}->{$directions[$i][1]} = 1;
                unless ($map->[$new_x][$new_y]->{visited})
                {
                    push @{$neighbours}, { x => $new_x, y => $new_y, value => $map->[$new_x][$new_y]->{value}};
                }
            }
        }

    }
    return { area => $area, perimeter => $perimeter, neighbours => $neighbours, plots => $plots };
}