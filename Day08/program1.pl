#!/usr/bin/perl -w

use strict;

my $fd;

open($fd, "<", "input2.txt") or die "Could not open input for reading";

my $map = ();
my $antennas = {};

my $y = 0;
my $width = 0;
my $height = 0;

while (my $line = <$fd>)
{
    $line =~ s/\n//;

    push @{$map}, [split //, $line];

    for (my $x = 0; $x < length($line); $x++)
    {
        my $char = substr($line, $x, 1);

        if ($char =~ /[a-zA-Z0-9]/)
        {
            if ($antennas->{$char})
            {
                push @{$antennas->{$char}}, { x => $x, y => $y };
            }
            else
            {
                $antennas->{$char} = [{ x => $x, y => $y }];
            }
        }
    }

    $y++;

    if (length($line) > $width)
    {
        $width = length($line);
    }

    $height++;
}

close $fd;

# foreach my $row (@{$map})
# {
#     print join("", @{$row}), "\n";
# }

# foreach my $antenna (keys %{$antennas})
# {
#     print "Antenna $antenna: ", join(", ", map { "($_->{x}, $_->{y})" } @{$antennas->{$antenna}}), "\n";
# }

find_antinodes($antennas, $width, $height, $map);

# foreach my $row (@{$map})
# {
#     print join("", @{$row}), "\n";
# }

my $count = count_antinodes($map);

print "Antinodes: $count\n";

sub find_antinodes
{
    my $antennas = shift;
    my $width = shift;
    my $height = shift;
    my $map = shift;

    foreach my $frequency (keys %{$antennas})
    {
        # print "Checking frequency $frequency\n";
        my $locations = $antennas->{$frequency};

        foreach my $first (@{$locations})
        {
            foreach my $second (@{$locations})
            {
                if ($first != $second)
                {
                    my $dx = ($second->{x} - $first->{x}) * 2;
                    my $dy = ($second->{y} - $first->{y}) * 2;

                    my $x = $first->{x} + $dx;
                    my $y = $first->{y} + $dy;

                    if ($x >= 0 && $x < $width && $y >= 0 && $y < $height)
                    {
                        $map->[$y]->[$x] = "#";
                    }

                    if ($dx % 3 == 0 && $dy % 3 == 0)
                    {
                        $x = $first->{x} + $dx / 3;
                        $y = $first->{y} + $dy / 3;

                        if ($x >= 0 && $x < $width && $y >= 0 && $y < $height)
                        {
                            $map->[$y]->[$x] = "#";
                        }
                    }
                }
            }
        }
    }
}

sub count_antinodes
{
    my $map = shift;

    for (my $y = 0; $y < scalar(@{$map}); $y++)
    {
        for (my $x = 0; $x < scalar(@{$map->[$y]}); $x++)
        {
            if ($map->[$y]->[$x] eq "#")
            {
                $count++;
            }
        }
    }

    return $count;
}
