#!/usr/bin/perl -w

use strict;

my $fd;

open $fd, '<', 'input2.txt' || die "Could not open input";

my $safe = 0;

while (my $line = <$fd>)
{
    $line =~ s/\n//;

    my @levels = split / /, $line;

    my $size = int(@levels);

    for (my $i = 0; $i < $size; $i++)
    {
        my @copy = @levels;
        splice(@copy, $i, 1);
        if (is_safe(@copy))
        {   
            $safe++;
            last;
        }
    }
}

close $fd;

print "Safe: $safe\n";

sub is_safe
{
    my @levels = @_;
    my $size = int(@levels);
    my $dir;
    my $is_safe = 1;

    for(my $i = 1; $i < $size; $i++)
    {
        my $current = $levels[$i];
        my $prev = $levels[$i-1];

        if (abs($current - $prev) > 3)
        {  
            $is_safe = 0;
            last;
        }

        if ($current == $prev)
        {  
            $is_safe = 0;
            last;
        }

        if ($dir)
        {
            my $mov = ($current - $prev) / abs($current - $prev);

            if ($mov != $dir)
            {  
                $is_safe = 0;
                last;
            }
        }
        else
        {
            $dir = ($current - $prev) / abs($current - $prev);
        }
    }

    return $is_safe;
}