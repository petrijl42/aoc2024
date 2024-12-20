#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $filename = "input2.txt";
    my $min_saving = 100;

    my $race = read_race_input($filename);
    my $count = count_cheats($race->{map}, $race->{start}, $race->{end}, $min_saving);

    print "Cheats: $count\n";
}

sub read_race_input
{
    my $filename = shift;

    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my $map = [];

    my $start;
    my $end;

    while (my $line = <$fd>)
    {
        chomp $line;

        if ((my $index = index($line, "S")) != -1)
        {
            die "Multiple start points" if defined $start;

            $start = {
                x => $index,
                y => scalar(@$map)
            };
        }
        if ((my $index = index($line, "E")) != -1)
        {
            die "Multiple end points" if defined $end;

            $end = {
                x => $index,
                y => scalar(@$map)
            };
        }

        my @row = split(//, $line);
        push(@$map, \@row);
    }

    close($fd);

    return {
        map => $map,
        start => $start,
        end => $end
    };
}

sub count_cheats
{
    my $map = shift;
    my $start = shift;
    my $end = shift;
    my $min_saving = shift;

    my $cheats = 0;
    my $lengths = {};

    my $step = 0;

    my $x = $start->{x};
    my $y = $start->{y};
    $lengths->{$x}->{$y} = $step;

    while ($x != $end->{x} || $y != $end->{y})
    {
        # print "X: $x, Y: $y\n";

        ($x, $y) = get_next_step($map, $x, $y, $lengths);
        $lengths->{$x}->{$y} = $step;
        my $shortcuts = get_shortcuts($map, $x, $y, $lengths, $min_saving);

        # foreach my $shortcut (keys %$shortcuts)
        # {
        #     print "Shortcut: $shortcut, Saving: $shortcuts->{$shortcut}\n";
        # }

        $cheats += scalar(keys %$shortcuts);

        $step++;
    }

    return $cheats;
}

sub is_valid_position
{
    my $map = shift;
    my $x = shift;
    my $y = shift;

    if ($y < 0 || $y >= scalar(@$map) || $x < 0 || $x >= scalar(@{$map->[$y]}))
    {
        return 0;
    }

    if ($map->[$y]->[$x] eq "#")
    {
        return 0;
    }

    return 1;
}

sub get_next_step
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $lengths = shift;

    foreach my $direction (([0, 1], [0, -1], [1, 0], [-1, 0]))
    {
        my $new_x = $x + $direction->[0];
        my $new_y = $y + $direction->[1];

        # print "New X: $new_x, New Y: $new_y\n";

        if (is_valid_position($map, $new_x, $new_y) && !defined $lengths->{$new_x}->{$new_y})
        {
            return ($new_x, $new_y);
        }
    }

    die "No path found";
}

sub get_shortcuts
{
    my $map = shift;
    my $x = shift;
    my $y = shift;
    my $lengths = shift;
    my $min_saving = shift;

    my $shortcuts = {};

    foreach my $direction (([0, 1], [0, -1], [1, 0], [-1, 0]))
    {
        my $new_x = $x + ($direction->[0] * 2);
        my $new_y = $y + ($direction->[1] * 2);

        next if !is_valid_position($map, $new_x, $new_y);

        if (defined $lengths->{$new_x}->{$new_y})
        {
            my $saving = $lengths->{$x}->{$y} - $lengths->{$new_x}->{$new_y} - 1;

            if ($saving >= $min_saving)
            {
                my $str = "$x,$y->$new_x,$new_y";
                $shortcuts->{$str} = $saving;
            }
        }
    }

    return $shortcuts;
}
