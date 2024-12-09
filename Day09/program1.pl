#!/usr/bin/perl -w

use strict;

my $fd;

open($fd, "<", "input2.txt") or die "Could not open input for reading";

my $line = <$fd> || die "Could not read from input";

$line =~ s/\n//;

close $fd;

my $index = 0;
my $type = 1;
my @disk;

foreach my $block (split //, $line)
{
    if ($type)
    {
        for (my $i = 0; $i < $block; $i++)
        {
            push @disk, $index;
        }
        $index++;
    }
    else
    {
        for (my $i = 0; $i < $block; $i++)
        {
            push @disk, undef;
        }
    }

    $type = !$type;
}

# print_disk(\@disk);
defrag(\@disk);
# print_disk(\@disk);
my $checksum = calculate_checksum(\@disk);

print "Checksum: $checksum\n";

sub print_disk
{
    my $disk = shift;

    foreach my $block (@{$disk})
    {
        print defined $block ? $block : ".";
    }

    print "\n";
}

sub defrag
{
    my $disk = shift;

    my $disksize = int(@{$disk});

    for (my $i = 0; $i < $disksize; $i++)
    {
        if (not defined $disk->[$i])
        {
            for (my $j = $disksize - 1; $j >= $i; $j--)
            {
                if (defined $disk->[$j])
                {
                    $disk->[$i] = $disk->[$j];
                    $disk->[$j] = undef;
                    last;
                }
            }
        }
    }
}

sub calculate_checksum
{
    my $disk = shift;

    my $disksize = int(@{$disk});

    my $sum = 0;

    for (my $i = 0; $i < $disksize; $i++)
    {
        if (defined $disk->[$i])
        {
            $sum += $disk->[$i] * $i;
        }
    }

    return $sum;
}
