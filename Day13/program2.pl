#!/usr/bin/perl -w

use strict;
use List::Util qw(min max);

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
    my $buttons = sort_buttons($machine->{buttons});

    my $result = find_prize($prize, $buttons);

    if (defined $result)
    {
        $total += get_price($machine->{buttons}, $result);
        # print "Prize found: $result->[0], $result->[1]\n";
    }
    else
    {
        # print "Prize not found\n";
    }
}

print "Total: $total\n";

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

sub find_prize
{
    my $prize = shift;
    my $buttons = shift;

    my $size = int(@{$buttons});

    my $combination = [(0) x $size];

    my $a = 0;

    for (my $i = 0; $i < 50; $i++)
    {
        get_button_max($prize, $buttons->[0], $buttons->[1]);
        get_button_min($prize, $buttons->[1], $buttons->[0]);
    }

    for (my $i = int($buttons->[0]->{max}) + 50; $i > int($buttons->[0]->{max}) - 50; $i--)
    {
        my $x = $prize->{x} - ($i * $buttons->[0]->{x});
        my $y = $prize->{y} - ($i * $buttons->[0]->{y});

        if ($x < 0 || $y < 0)
        {
            next;
        }

        if ($x % $buttons->[1]->{x} == 0 && $y % $buttons->[1]->{y} == 0)
        {
            my $a = $x / $buttons->[1]->{x};
            my $b = $y / $buttons->[1]->{y};

            if ($a == $b)
            {
                return [$a, $i];
            }
        }
    }

    return undef;
}

sub get_button_max
{
    my $target = shift;
    my $primary = shift;
    my $secondary = shift;

    if (not defined $secondary->{min})
    {
        $secondary->{min} = 0;
    }

    my $x = $target->{x} - ($secondary->{min} * $secondary->{x});
    my $y = $target->{y} - ($secondary->{min} * $secondary->{y});

    my $max_x = ($target->{x} - ($secondary->{min} * $secondary->{x})) / $primary->{x};
    my $max_y = ($target->{y} - ($secondary->{min} * $secondary->{y})) / $primary->{y};

    $primary->{max} = min($max_x, $max_y);
}

sub get_button_min
{
    my $target = shift;
    my $primary = shift;
    my $secondary = shift;

    if (not defined $secondary->{max})
    {
        $secondary->{max} = get_button_max($target, $secondary, $primary);
    }

    my $min_x = ($target->{x} - ($secondary->{max} * $secondary->{x})) / $primary->{x};
    my $min_y = ($target->{y} - ($secondary->{max} * $secondary->{y})) / $primary->{y};

    $primary->{min} = max($min_x, $min_y);
}

sub sort_buttons
{
    my $buttons = shift;

    my @sorted = sort { $a->{price} <=> $b->{price} } @{$buttons};

    return \@sorted;
}
