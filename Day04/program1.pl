#!/usr/bin/perl -w

use strict;

my $fd;

open ($fd, '<', "input2.txt") || die 'Could not open input for reading';

my $data = ();

while (my $line = <$fd>)
{
    my @letters = split //, $line;

    push @{$data}, \@letters;
}

my $count = 0;

for (my $x = 0; $x < int(@{$data}); $x++)
{
    for (my $y = 0; $y < int(@{$data->[$x]}); $y++)
    {
        my $letter = $data->[$x]->[$y]; 
        #print "$letter";

        $count += find_words($data, 'XMAS', $x, $y);
    }
}

print "Count: $count\n";

sub find_words
{
    my $data = shift;
    my $word = shift;
    my $x = shift;
    my $y = shift;
    my @letters = split //, $word;

    my @directions = (-1, 0, 1);

    my $count = 0;

    foreach my $x_dir (@directions)
    {
        foreach my $y_dir (@directions)
        {
            my $valid = 1;

            for (my $offset = 0; $offset < int(@letters); $offset++)
            {
                my $pos_x = $x + ($x_dir * $offset);
                my $pos_y = $y + ($y_dir * $offset);

                if (($pos_x < 0) || ($pos_y < 0) ||
                    (not defined $data->[$pos_x]->[$pos_y]) ||
                    ($data->[$pos_x]->[$pos_y] ne $letters[$offset]))
                {
                    $valid = 0;
                    last;
                };
            }

            if ($valid)
            {
                #print "$x, $y, $x_dir, $y_dir\n";
                $count++;
            }
        }
    }

    return $count;
}
