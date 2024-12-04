#!/usr/bin/perl -w

use strict;

my $fd;

open($fd, '<', "input1.txt") || die "Could not open input for reading";

my @first;
my @second;

while (my $line = <$fd>)
{
    my ($first, $second) = $line =~ /^(\d+)\s+(\d+)$/;

    push @first, $first;
    push @second, $second;
}

@first = sort @first;
@second = sort @second;

my $diff = 0;

my $size = int(@first);
for (my $i = 0; $i < $size; $i++)
{
    $diff += abs($first[$i] - $second[$i])
}

print "Diff $diff\n";
