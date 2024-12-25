#!/usr/bin/perl -w

use strict;
use Data::Dumper;

main();

sub main
{
    my $input = read_input("input2.txt");
    my $count = count_fitting($input->{keys}, $input->{locks});

    print "Count: $count\n";
}

sub read_input
{
    my $filename = shift;

    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading.";

    my @keys;
    my @locks;

    while (my $line = <$fd>)
    {
        chomp $line;

        my @first = split //, $line;

        if ($line =~ /^#+$/)
        {
            push @locks, get_heights($fd, \@first, 0);
        }
        elsif ($line =~ /^\.+$/)
        {
            push @keys, get_heights($fd, \@first, 1);
        }
        else
        {
            die "Invalid line: $line";
        }
    }

    close $fd;

    return { keys => \@keys, locks => \@locks };
}

sub get_heights
{
    my $fd = shift;
    my $compare = shift;
    my $key = shift;

    my @heights;
    my $row = 0;

    while (my $line = <$fd>)
    {
        chomp $line;
        my @array = split //, $line;

        last if $line eq "";

        for (my $i = 0; $i < scalar @$compare; $i++)
        {
            if (($array[$i] ne $compare->[$i]) && (not defined $heights[$i]))
            {
                $heights[$i] = $row;
            }
        }

        $row++;
    }

    if ($key)
    {
        for (my $i = 0; $i < scalar @heights; $i++)
        {
            $heights[$i] = $row - $heights[$i] - 1;
        }
    }

    return \@heights;
}

sub count_fitting
{
    my $keys = shift;
    my $locks = shift;

    my $count = 0;

    foreach my $key (@$keys)
    {
        foreach my $lock (@$locks)
        {
            $count++ if check_fit($key, $lock);
        }
    }

    return $count;
}

sub check_fit
{
    my $key = shift;
    my $lock = shift;

    for (my $i = 0; $i < scalar @$key; $i++)
    {
        return 0 if ($key->[$i] + $lock->[$i] > 5);
    }

    return 1;
}
