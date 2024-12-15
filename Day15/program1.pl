#!/usr/bin/perl -w

use strict;
use Switch;

main ();

sub main
{
    my $filename = "input2.txt";

    my ($map, $movements) = read_input($filename);
    # print_map($map);
    update_movements_to_map($map, $movements);
    # print_map($map);
    my $sum = get_gps_sum($map);

    print "GPS sum: $sum\n";
}

sub read_input
{
    my $filename = shift;

    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my $map = read_map($fd);
    my $movements = read_movements($fd);

    close $fd;

    return ($map, $movements);
}

sub read_map
{
    my $fd = shift;

    my $width;
    my @data;
    my $position;

    while (my $line = <$fd>)
    {
        chomp $line;

        last if (length($line) == 0);

        if (not defined $width)
        {
            $width = length($line);
        }
        die "Invalid map: $line\n" if (length($line) != $width);

        if ((my $x = index($line, "@")) != -1)
        {
            die "Invalid map, multiple robots\n" if (defined $position);

            $position = { x => $x, y => scalar(@data) };
        }

        push @data, [ split //, $line ];
    }

    my $map = {
        width => $width,
        height => scalar(@data),
        data => \@data,
        position => $position
    };

    return $map;
}

sub read_movements
{
    my $fd = shift;
    my @movements;

    while (my $line = <$fd>)
    {
        chomp $line;

        my @symbols = split //, $line;

        foreach my $symbol (@symbols)
        {
            switch ($symbol)
            {
                case "^" { push @movements, { x =>  0, y => -1}; }
                case ">" { push @movements, { x =>  1, y =>  0}; }
                case "v" { push @movements, { x =>  0, y =>  1}; }
                case "<" { push @movements, { x => -1, y =>  0}; }
                else { die "Invalid movement: $symbol\n"; }
            }
        }
    }

    return \@movements;
}

sub print_map
{
    my $map = shift;

    for my $row (@{$map->{data}})
    {
        print join("", @$row), "\n";
    }

    print "Position: $map->{position}->{x}, $map->{position}->{y}\n";
}

sub update_movements_to_map
{
    my $map = shift;
    my $movements = shift;

    foreach my $movement (@$movements)
    {
        my $count = get_movement_count($map, $movement);
        # print "Count: $count\n";
        if ($count)
        {
            move_robot($map, $movement, $count);
        }
        # print_map($map);
    }
}

sub get_movement_count
{
    my $map = shift;
    my $direction = shift;

    my $count = 1;
    my $x = $map->{position}->{x};
    my $y = $map->{position}->{y};

    while (1)
    {
        $x += $direction->{x};
        $y += $direction->{y};

        die "Edge of map reached without hitting the wall." if ($x < 0 || $x >= $map->{width} || $y < 0 || $y >= $map->{height});

        switch ($map->{data}->[$y]->[$x])
        {
            case "#" { return 0; }
            case "." { return $count; }
            case "O" { $count++; }
            else { die "Invalid map symbol: $map->{data}->[$y]->[$x]\n"; }
        }
    }
}

sub move_robot
{
    my $map = shift;
    my $direction = shift;
    my $count = shift;

    my $x = $map->{position}->{x};
    my $y = $map->{position}->{y};

    for (my $i = $count; $count > 0; $count--)
    {
        my $from_x = $x + $direction->{x} * ($count - 1);
        my $from_y = $y + $direction->{y} * ($count - 1);

        my $to_x = $x + $direction->{x} * $count;
        my $to_y = $y + $direction->{y} * $count;

        # print "Moving from $from_x, $from_y to $to_x, $to_y\n";

        $map->{data}->[$to_y]->[$to_x] = $map->{data}->[$from_y]->[$from_x];
        $map->{data}->[$from_y]->[$from_x] = ".";
    }

    $map->{position}->{x} += $direction->{x};
    $map->{position}->{y} += $direction->{y};
}

sub get_gps_sum
{
    my $map = shift;

    my $sum = 0;

    for (my $x = 0; $x < $map->{width}; $x++)
    {
        for (my $y = 0; $y < $map->{height}; $y++)
        {
            if ($map->{data}->[$y]->[$x] eq "O")
            {
                $sum += $x + $y * 100;
            }
        }
    }

    return $sum;
}