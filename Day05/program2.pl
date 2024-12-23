#!/usr/bin/perl -w

use strict;

my $fd;

open ($fd, '<', "input2.txt") || die 'Could not open input for reading';

my %order;
my @manuals;

while (my $line = <$fd>)
{
    $line =~ s/\n//;

    if ($line =~ /^(\d+)\|(\d+)$/)
    {
        my ($key, $value) = $line =~ /^(\d+)\|(\d+)$/;
        if (not defined $order{$key})
        {
            $order{$key} = ();
        }
        push @{$order{$key}}, $value;
    }
    elsif ($line =~ /^(\d+,)*(\d+)$/)
    {
        my @pages = split /,/, $line;
        push @manuals, \@pages;
    }
}

close $fd;

my $total = 0;

foreach my $manual (@manuals)
{
    if (not check_order($manual, \%order))
    {
        my @sorted = sort_order($manual, \%order);

        #print join(",", @{$manual}) . " -> ";
        #print join(",", @sorted) . "\n";

        $total += get_middle_value(\@sorted);
    }
}

print "Total: $total\n";

sub check_order
{
    my $pages = shift;
    my $order = shift;

    for (my $i = int(@{$pages}) - 1; $i > 0; $i--)
    {
        my $page = $pages->[$i];

        foreach my $rule (@{$order->{$page}})
        {
            for (my $j = $i - 1; $j >= 0; $j--)
            {
                my $comp_page = $pages->[$j];

                if ($rule == $comp_page)
                {
                    return 0;
                }
            }
        }
    }

    return 1;
}

sub sort_order
{
    my $pages = shift;
    my $order = shift;

    my @sorted = sort
    {
        if (defined $order->{$a})
        {
            foreach my $rule (@{$order->{$a}})
            {
                if ($rule == $b) { return -1 };
            }
        }
        if (defined $order->{$b})
        {
            foreach my $rule (@{$order->{$b}})
            {
                if ($rule == $a) { return 1 };
            }
        }
        return 0;
    } @{$pages};

    return @sorted;
}

sub get_middle_value
{
    my $pages = shift;

    my $middle = int(int(@{$pages}) / 2);

    return $pages->[$middle];
}