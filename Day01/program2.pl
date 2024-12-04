#!/usr/bin/perl -w

use strict;

my $fd;

open($fd, '<', "input1.txt") || die "Could not open input for reading";

my @first;
my %second;

while (my $line = <$fd>)
{
    my ($first, $second) = $line =~ /^(\d+)\s+(\d+)$/;

    push @first, $first;
    if (defined $second{$second})
    {
        $second{$second}++;
    }
    else
    {
        $second{$second} = 1;
    }
}

close $fd;

my $similarity = 0;

my $size = int(@first);
for (my $i = 0; $i < $size; $i++)
{
    my $value = $first[$i];
    if (defined $second{$value})
    {
        #print "$value ". $second{$value} ."\n";
        $similarity += ($value * $second{$value})
    }
}

print "Similarity $similarity\n";
