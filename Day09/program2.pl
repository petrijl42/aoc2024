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

foreach my $size (split //, $line)
{
    if ($size > 0)
    {
        if ($type)
        {
            push @disk, { id => $index, size => $size };
            $index++;
        }
        else
        {
            if (not defined $disk[-1]->{id})
            {
                # print "Increasing empty size: $size\n";
                $disk[-1]->{size} += $size;
            }
            else
            {
                push @disk, { size => $size };
            }
        }
    }

    $type = !$type;
}

# print_disk(\@disk);
my $result = defrag(\@disk);
# print_disk($result);
my $checksum = calculate_checksum($result);

print "Checksum: $checksum\n";

sub print_disk
{
    my $disk = shift;

    foreach my $block (@{$disk})
    {
        if (defined $block->{id})
        {
            print $block->{id} x $block->{size};
        }
        else
        {
            print "." x $block->{size};
        }
    }

    print "\n";
}

sub defrag
{
    my $disk = shift;
    my $result = ();

    my $disksize = int(@{$disk});

    for (my $i = 0; $i < $disksize; $i++)
    {
        my $more;

        do
        {
            $more = 0;

            if (not defined $disk->[$i]->{id})
            {
                for (my $j = $disksize - 1; $j >= $i; $j--)
                {
                    if (defined $disk->[$j]->{id} && $disk->[$i]->{size} >= $disk->[$j]->{size})
                    {
                        push @{$result}, $disk->[$j];
                        $disk->[$i]->{size} -= $disk->[$j]->{size};
                        $more = 1 if ($disk->[$i]->{size} > 0);
                        $disk->[$j] = { size => $disk->[$j]->{size} };
                        last;
                    }
                }
            }
            else
            {
                push @{$result}, $disk->[$i];
            }
        }
        while ($more);

        if (not defined $disk->[$i]->{id} && $disk->[$i]->{size} > 0)
        {
            push @{$result}, $disk->[$i];
        }
    }

    return $result;
}

sub calculate_checksum
{
    my $disk = shift;

    my $disksize = int(@{$disk});

    my $index = 0;
    my $sum = 0;

    for (my $i = 0; $i < $disksize; $i++)
    {
        if (defined $disk->[$i]->{id})
        {
            for (my $j = 0; $j < $disk->[$i]->{size}; $j++)
            {
                $sum += $disk->[$i]->{id} * ($index + $j);
            }
        }

        $index = $index + $disk->[$i]->{size};
    }

    return $sum;
}
