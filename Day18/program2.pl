#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $count = 0;
    my $start_x = 0;
    my $start_y = 0;
    my $max_x = 70;
    my $max_y = 70;

    my ($corrupted_hash, $corrupted_array) = read_corrupted("input2.txt");
    my $first = find_first_blocked_path($corrupted_hash, $start_x, $start_y, $max_x, $max_y, $count);

    die "Could not find first blocked path\n" if ($first == -1);

    my $coords = $corrupted_array->[$first - 1];

    print "Result: $coords->{x},$coords->{y}\n";
}

sub read_corrupted
{
    my $filename = shift;
    my $fd;
    open($fd, "<", $filename) or die "Could not open input for reading";

    my $position = 1;
    my $hash = {};
    my $array = [];

    while (my $line = <$fd>)
    {
        chomp $line;

        next if ($line eq "");

        if ($line =~ /^(\d+),(\d+)$/)
        {
            my $x = $1;
            my $y = $2;

            $hash->{$x}->{$y} = $position++;
            push(@$array, { x => $x, y => $y });
        }
        else
        {
            die "Invalid input\n";
        }
    }

    close($fd);

    return $hash, $array;
}

sub find_path
{
    my $corrupted = shift;
    my $x = shift;
    my $y = shift;
    my $max_x = shift;
    my $max_y = shift;
    my $count = shift;

    my %visited;
    my @paths = ({ x => $x, y => $y, score => 0 });

    while (@paths)
    {
        my $path = shift @paths;

        # print "Path: $path->{x}, $path->{y}, $path->{score}\n";

        if ($path->{x} == $max_x && $path->{y} == $max_y)
        {
            return $path->{score};
        }

        if ($visited{$path->{x}}->{$path->{y}})
        {
            next;
        }

        $visited{$path->{x}}->{$path->{y}} = 1;

        my @new_paths = ({ x => $path->{x} + 1, y => $path->{y}, score => $path->{score} + 1 },
                         { x => $path->{x} - 1, y => $path->{y}, score => $path->{score} + 1 },
                         { x => $path->{x}, y => $path->{y} + 1, score => $path->{score} + 1 },
                         { x => $path->{x}, y => $path->{y} - 1, score => $path->{score} + 1 });

        foreach my $new_path (@new_paths)
        {
            if ($new_path->{x} < 0 || $new_path->{x} > $max_x || $new_path->{y} < 0 || $new_path->{y} > $max_y)
            {
                next;
            }

            if ($corrupted->{$new_path->{x}}->{$new_path->{y}} && $corrupted->{$new_path->{x}}->{$new_path->{y}} <= $count)
            {
                next;
            }

            push(@paths, $new_path);
        }
    }

    return -1;
}

sub find_first_blocked_path
{
    my $corrupted = shift;
    my $x = shift;
    my $y = shift;
    my $max_x = shift;
    my $max_y = shift;
    my $count = shift;

    my $max_count = 5000;

    while ($count <= $max_count)
    {
        # print "Trying count: $count\n";
        my $result = find_path($corrupted, $x, $y, $max_x, $max_y, $count);
        # print "Result: $result\n";

        if ($result == -1)
        {
            return $count;
        }

        $count++;
    }

    return -1;
}
