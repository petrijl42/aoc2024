#!/usr/bin/perl -w

use strict;
use List::Util qw(min max);
use Data::Dumper;

main();

sub main
{
    my $fd;

    open($fd, "<", "input2.txt") or die "Could not open input for reading";

    my @machines;

    my $prize;
    my $buttons;

    while (my $line = <$fd>)
    {
        chomp $line;

        if ($line =~ /Button ([AB]): X\+(\d+), Y\+(\d+)/)
        {
            my $name = $1;
            my $x = $2;
            my $y = $3;

            my $price;

            if ($name eq 'A')
            {
                $price = 3;
            }
            elsif ($name eq 'B')
            {
                $price = 1;
            }
            else
            {
                die "Invalid button name: $name\n";
            }

            push @{$buttons}, { name => $name, x => $x, y => $y, price => $price };
        }
        elsif ($line =~ /Prize: X=(\d+), Y=(\d+)/)
        {
            my $x = $1 + 10000000000000;
            my $y = $2 + 10000000000000;

            $prize = { x => $x, y => $y };
        }
        elsif ($line eq '')
        {
            if (defined $prize && defined $buttons)
            {
                push @machines, { prize => $prize, buttons => $buttons };

                $prize = undef;
                $buttons = undef;
            }
            else
            {
                die "Invalid input. Missing prize or buttons\n";
            }
        }
        else
        {
            die "Invalid input: $line\n";
        }
    }

    if (defined $prize && defined $buttons)
    {
        push @machines, { prize => $prize, buttons => $buttons };
    }

    close($fd);

    my $total = 0;

    foreach my $machine (@machines)
    {
        my $prize = $machine->{prize};
        my $buttons = $machine->{buttons};

        my $result = get_button_counts($prize, $buttons);

        if (defined $result)
        {
            $total += get_price($buttons, $result);
            # print "Prize found: $result->[0], $result->[1]\n";
        }
        else
        {
            # print "Prize not found\n";
        }
    }

    print "Total: $total\n";
}

sub get_price
{
    my $buttons = shift;
    my $combination = shift;

    my $size = int(@{$buttons});
    my $price = 0;

    for (my $i = 0; $i < $size; $i++)
    {
        $price += $buttons->[$i]->{price} * $combination->[$i];
    }

    return $price;
}

sub get_button_counts
{
    my $prize = shift;
    my $buttons = shift;

    my @result = (
        get_count($prize, $buttons->[0], $buttons->[1]),
        get_count($prize, $buttons->[1], $buttons->[0])
    );

    if ($result[0] != int($result[0]) || $result[1] != int($result[1]))
    {
        return undef;
    }

    return \@result;
}

# a * ax + b * bx = x | * by
# a * ay + b * by = y | * bx
#
# a * ax * by + b * bx * by = x * by | substract the two equations
# a * ay * bx + b * bx * by = y * bx
#
# a * ax * by - a * ay * bx = x * by - y * bx
#
# a * (ax * by - ay * bx) = x * by - y * bx | / (ax * by - ay * bx)
#
# a = (x * by - y * bx) / (ax * by - ay * bx)

sub get_count
{
    my $prize = shift;
    my $button1 = shift;
    my $button2 = shift;

    my $count = ($prize->{x} * $button2->{y} - $prize->{y} * $button2->{x}) / ($button1->{x} * $button2->{y} - $button1->{y} * $button2->{x});

    return $count;
}