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
    print " ";

    for (my $x = 0; $x < scalar @{$map}; $x++)
    {
        print $x;
    }
    print "\n";
    for (my $x = 0; $x < scalar @{$map}; $x++)
    {
        print $x;
        for (my $y = 0; $y < scalar @{$map->[$x]}; $y++)
        {
            print $map->[$x][$y]->{value};
        }

        print "\n";
    }
}

my $value = check_map($map);

print "Value: $value\n";

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

        my $info = get_area_info($map, $item->{x}, $item->{y});

        foreach my $neighbour (@{$info->{neighbours}})
        {
            push @check_list, $neighbour;
        }

        $value += $info->{area} * $info->{perimeter};
        # print "Value: " . $map->[$x][$y]->{value} . "\n";
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

    my $plots = [{ x => $x, y => $y, value => $map->[$x][$y]->{value} }];
    my $neighbours = [];
    my $area = 0;
    my $perimeter = 0;

    foreach my $plot (@{$plots})
    {
        my $info = get_plot_info($map, $plot);
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

    my $x = $plot->{x};
    my $y = $plot->{y};

    my @directions = ([0, 1], [1, 0], [0, -1], [-1, 0]);
    my $neighbours = [];
    my $plots = [];
    my $area = 0;
    my $perimeter = 0;

    unless ($map->[$x][$y]->{visited})
    {
        my $value = $map->[$x][$y]->{value};
        $map->[$x][$y]->{visited} = 1;
        $area++;

        for (my $i = 0; $i < scalar @directions; $i++)
        {
            my $new_x = $x + $directions[$i][0];
            my $new_y = $y + $directions[$i][1];
            my $new_plot = $map->[$new_x][$new_y];
            my $new_value = $new_plot->{value};

            if ($new_x < 0 || $new_x >= scalar @{$map} || $new_y < 0 || $new_y >= scalar @{$map->[$new_x]})
            {
                $perimeter++;
                next;
            }

            if ($value eq $new_value)
            {
                next if ($new_plot->{visited});

                push @{$plots}, { x => $new_x, y => $new_y, value => $new_value };
            }
            else
            {
                $perimeter++;
                unless ($new_plot->{visited})
                {
                    push @{$neighbours}, { x => $new_x, y => $new_y, value => $new_value};
                }
            }
        }

    }
    return { area => $area, perimeter => $perimeter, neighbours => $neighbours, plots => $plots };
}