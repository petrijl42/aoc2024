#!/usr/bin/perl -w

use strict;
use Switch;

main ();

sub main
{
    my $maze = read_maze("input2.txt");
    my $score = walk_maze($maze);

    print "Score: $score\n";
}

sub read_maze
{
    my $filename = shift;
    my $fd;
    open($fd, "<", $filename) or die "Could not open input for reading";

    my $start;
    my $map = [];

    while (my $line = <$fd>)
    {
        chomp $line;

        if ((my $x = index($line, "S")) != -1)
        {
            die "Invalid map, multiple starting points\n" if (defined $start);

            $start = { x => $x, y => scalar(@{$map}) };
        }

        push(@$map, [split(//, $line)]);
    }

    close($fd);

    return { map => $map, start => $start, direction => { x => 1, y => 0 } };
}

sub walk_maze
{
    my $maze = shift;

    my $position = $maze->{start};
    my $direction = $maze->{direction};
    my $map = $maze->{map};

    my $score;
    my $visited = {};

    my @paths = ({ position => $position, direction => turn_counter_clockwise($direction), score => 1000 },
                 { position => $position, direction => turn_clockwise($direction), score => 1000 },
                 { position => $position, direction => $direction, score => 0 });

    while (@paths > 0)
    {
        my $path = pop @paths;
        my $x = $path->{position}->{x} + $path->{direction}->{x};
        my $y = $path->{position}->{y} + $path->{direction}->{y};

        if ($y < 0 or $y >= scalar(@$map) or $x < 0 or $x >= scalar(@{$map->[$y]}))
        {
            die "Exited map without hitting a wall\n";
        }

        next if ((defined $score) && ($path->{score} > $score));

        # my $label = "$x,$y";
        if (defined $visited->{$x}->{$y} and $visited->{$x}->{$y} <= $path->{score})
        {
            next;
        }
        $visited->{$x}->{$y} = $path->{score};
        $path->{score}++;

        switch ($map->[$y]->[$x])
        {
            case "#"
            {
            }
            case "S"
            {
            }
            case "."
            {
                push @paths,
                {
                    position => { x => $x, y => $y },
                    direction => turn_counter_clockwise($path->{direction}),
                    score => $path->{score} + 1000
                };

                push @paths,
                {
                    position => { x => $x, y => $y },
                    direction => turn_clockwise($path->{direction}),
                    score => $path->{score} + 1000
                };

                push @paths,
                {
                    position => { x => $x, y => $y },
                    direction => $path->{direction},
                    score => $path->{score}
                };
            }
            case "E"
            {
                # print "Score: $path->{score}\n";
                if (not defined $score or $path->{score} < $score)
                {
                    $score = $path->{score};
                }
            }
            else
            {
                die "Invalid character $map->[$y]->[$x] in map\n";
            }
        }
    }

    return $score;
}

sub turn_clockwise
{
    my $direction = shift;

    my $new_direction = { x => $direction->{y} * - 1, y => $direction->{x} };

    return $new_direction;
}

sub turn_counter_clockwise
{
    my $direction = shift;

    my $new_direction = { x => $direction->{y}, y => $direction->{x} * -1 };

    return $new_direction;
}
