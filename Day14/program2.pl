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

    my $max = 0;
    # Loop size 10403
    while ($multiplier < 10403)
    {
        my $map = get_robot_positions_map($robots, $dimensions, $multiplier);

        if (no_multiples($map))
        {
            print_map($map, $dimensions);
            print "Found at $multiplier\n";

            last;
        }

        $multiplier++;
    }
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

sub no_multiples
{
    my $map = shift;

    foreach my $value (@{$map})
    {
        if ($value > 1)
        {
            return 0;
        }
    }

    return 1;
}
