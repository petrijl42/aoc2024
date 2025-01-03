#!/usr/bin/perl -w

use strict;

main ();

sub main
{
    my $multiplier = 0;

    # my $dimensions = { x => 11, y => 7 };
    # my $robots = read_input("input1.txt");

    my $dimensions = { x => 101, y => 103 };
    my $robots = read_input("input2.txt");

    my $min_score;
    my $result = 0;
    # Loop size 10403
    while ($multiplier < 10403)
    {
        my $score = get_safety_score($robots, $dimensions, $multiplier);

        if ((not defined $min_score) || $score < $min_score)
        {
            $min_score = $score;
            $result = $multiplier;
        }

        $multiplier++;
    }

    my $map = get_robot_positions_map($robots, $dimensions, $result);

    print_map($map, $dimensions);
    print "Found at $result\n";
}


sub read_input
{
    my $filename = shift;
    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my $robots = [];

    while (my $line = <$fd>)
    {
        chomp $line;

        if ($line =~ /p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/)
        {
            my $x = $1;
            my $y = $2;
            my $vx = $3;
            my $vy = $4;

            push @{$robots}, { x => $x, y => $y, vx => $vx, vy => $vy };
        }
        else
        {
            die "Invalid input: $line\n";
        }
    }

    close($fd);

    return $robots;
}

sub get_robot_positions_map
{
    my $robots = shift;
    my $dimensions = shift;
    my $multiplier = shift;

    my @map = (0) x ($dimensions->{x} * $dimensions->{y});

    foreach my $robot (@{$robots})
    {
        my $x = ($robot->{x} + $multiplier * $robot->{vx}) % $dimensions->{x};
        my $y = ($robot->{y} + $multiplier * $robot->{vy}) % $dimensions->{y};

        my $index = $y * $dimensions->{x} + $x;
        $map[$index]++;
    }

    return \@map;
}

sub print_map
{
    my $map = shift;
    my $dimensions = shift;

    for (my $y = 0; $y < $dimensions->{y}; $y++)
    {
        for (my $x = 0; $x < $dimensions->{x}; $x++)
        {
            my $index = $y * $dimensions->{x} + $x;
            my $value = $map->[$index];
            print $value > 0 ? $value : " ";
        }
        print "\n";
    }
}

sub get_safety_score
{
    my $robots = shift;
    my $dimensions = shift;
    my $multiplier = shift;

    my $score = 0;

    my $middle_x = int($dimensions->{x} / 2);
    my $middle_y = int($dimensions->{y} / 2);

    my @quadrants = (0, 0, 0, 0);

    foreach my $robot (@{$robots})
    {
        my $x = ($robot->{x} + $multiplier * $robot->{vx}) % $dimensions->{x};
        my $y = ($robot->{y} + $multiplier * $robot->{vy}) % $dimensions->{y};

        my $quadrant = 0;

        next if ($x == $middle_x || $y == $middle_y);

        if ($x > $middle_x)
        {
            $quadrant += 1;
        }
        if ($y > $middle_y)
        {
            $quadrant += 2;
        }

        # print "Robot: $x, $y, $quadrant\n";

        $quadrants[$quadrant]++;
    }

    $score = multiply(\@quadrants);

    return $score;
}

sub multiply
{
    my $array = shift;

    my $result = 1;

    foreach my $element (@{$array})
    {
        $result *= $element;
    }

    return $result;
}