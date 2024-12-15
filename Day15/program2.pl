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
        $line =~ s/#/##/g;
        $line =~ s/O/\[\]/g;
        $line =~ s/\./../g;
        $line =~ s/@/@./g;


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
        my $items = get_items_to_move($map, $map->{position}->{x}, $map->{position}->{y}, $movement);

        if ($items)
        {
            move_items($map, $movement, $items);
        }
        # print_map($map);
    }
}

sub get_items_to_move
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $direction = shift;

    my $items = [{ x => $x, y => $y }];

    my $dest_x = $x + $direction->{x};
    my $dest_y = $y + $direction->{y};

    # print "From: $x, $y to $dest_x, $dest_y\n";

    die "Edge of map reached without hitting the wall." if ($dest_x < 0 || $dest_x >= $map->{width} || $dest_y < 0 || $dest_y >= $map->{height});

    switch ($map->{data}->[$dest_y]->[$dest_x])
    {
        case "#"
        {
            return undef;
        }
        case "."
        {
            return $items;
        }
        case "O"
        {
            my $children = get_items_to_move($map, $dest_x, $dest_y, $direction);
            return undef if (not $children);

            @{$items} = (@$children, @$items);

            return $items;
        }
        case "["
        {
            if ($map->{data}->[$dest_y]->[$dest_x + 1] ne "]")
            {
                die "Invalid map symbol: $map->{data}->[$dest_y]->[$dest_x]\n";
            }

            my $children = get_items_to_move($map, $dest_x, $dest_y, $direction);
            return undef if (not $children);

            @{$items} = (@$children, @$items);

            if ($direction->{y} != 0)
            {
                $children = get_items_to_move($map, $dest_x + 1, $dest_y, $direction);
                return undef if (not $children);

                @{$items} = (@$children, @$items);
            }

            return $items;
        }
        case "]"
        {
            if ($map->{data}->[$dest_y]->[$dest_x - 1] ne "[")
            {
                die "Invalid map symbol: $map->{data}->[$dest_y]->[$dest_x]\n";
            }

            my $children = get_items_to_move($map, $dest_x, $dest_y, $direction);
            return undef if (not $children);

            @{$items} = (@$children, @$items);

            if ($direction->{y} != 0)
            {
                $children = get_items_to_move($map, $dest_x - 1, $dest_y, $direction);
                return undef if (not $children);

                @{$items} = (@$children, @$items);
            }

            return $items;
        }
        else
        {
            die "Invalid map symbol: $map->{data}->[$dest_y]->[$dest_x]\n";
        }
    }
}

sub move_items
{
    my $map = shift;
    my $direction = shift;
    my $items = shift;

    my $completed = {};

    foreach my $item (@$items)
    {
        my $from_x = $item->{x};
        my $from_y = $item->{y};

        next if (defined $completed->{$from_x}->{$from_y});
        $completed->{$from_x}->{$from_y} = 1;

        my $to_x = $from_x + $direction->{x};
        my $to_y = $from_y + $direction->{y};

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
            if ($map->{data}->[$y]->[$x] eq "O" || $map->{data}->[$y]->[$x] eq "[")
            {
                $sum += $x + $y * 100;
            }
        }
    }

    return $sum;
}