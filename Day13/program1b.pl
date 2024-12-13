#!/usr/bin/perl -w

use strict;

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
        my $x = $1;
        my $y = $2;

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
        $total += get_price($buttons, $result);
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

    my $max_x = int($prize->{x} / $buttons->[1]->{x});
    my $max_y = int($prize->{y} / $buttons->[1]->{y});
    my $max = $max_x < $max_y ? $max_x : $max_y;

    for (my $i = 0; $i <= $max; $i++)
    {
        my $x = $prize->{x} - (($max-$i) * $buttons->[1]->{x});
        my $y = $prize->{y} - (($max-$i) * $buttons->[1]->{y});

        if ($x < 0 || $y < 0)
        {
            next;
        }

        if ($x % $buttons->[0]->{x} == 0 && $y % $buttons->[0]->{y} == 0)
        {
            my $a = $x / $buttons->[0]->{x};
            my $b = $y / $buttons->[0]->{y};

            if ($a == $b)
            {
                return [$a, ($max-$i)];
            }
        }
    }

    return undef;
}

sub next_combination
{
    my $buttons = shift;
    my $max = shift;

    my $size = int(@{$buttons});

    for (my $i = 0; $i < $size; $i++)
    {
        if ($buttons->[$i] < $max)
        {
            $buttons->[$i]++;
            return 1;
        }
        else
        {
            $buttons->[$i] = 0;
        }
    }

    return 0;
}

sub sort_buttons
{
    my $buttons = shift;

    my @sorted = sort { $a->{price} <=> $b->{price} } @{$buttons};

    return \@sorted;
}
