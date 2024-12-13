#!/usr/bin/perl -w

use strict;
use List::Util qw(min max);
use Data::Dumper;

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

# print Dumper(\@machines);

my $total = 0;

foreach my $machine (@machines)
{
    my $prize = $machine->{prize};
    my $buttons = sort_buttons($machine->{buttons});

    my $result = find_prize($prize, $buttons);

    if (defined $result)
    {
        print "Prize found: $result->[0], $result->[1]\n";
        print "Price: " . get_price($machine->{buttons}, $result) . "\n";
        $total += get_price($machine->{buttons}, $result);
        # print "Prize found: $result->[0], $result->[1]\n";
    }
    else
    {
        print "Prize not found\n";
    }

    # exit 0;
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
        print "$buttons->[$i]->{price} * $combination->[$i]\n";
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

    # $buttons->[0]->{max} = int($prize->{y} / $buttons->[0]->{y});
    # for (my $i = 0; $i < $size; $i++)
    # {
    #     my $max_x = int($prize->{x} / $buttons->[$i]->{x});
    #     my $max_y = int($prize->{y} / $buttons->[$i]->{y});
    #     my $max = $max_x < $max_y ? $max_x : $max_y;
    #     $buttons->[$i]->{max} = $max;
    #     $buttons->[$i]->{min} = 0;
    # }

    # print Dumper($buttons);

    for (my $i = 0; $i < 10000; $i++)
    {
        # print "foo\n";
        get_button_max($prize, $buttons->[0], $buttons->[1]) or last;
    # print Dumper($buttons);
        get_button_min($prize, $buttons->[1], $buttons->[0]) or last;
    # print Dumper($buttons);
    # get_button_max($prize, $buttons->[0], $buttons->[1]);
    # print Dumper($buttons);
    # get_button_min($prize, $buttons->[1], $buttons->[0]);
    # print Dumper($buttons);
    # get_button_max($prize, $buttons->[0], $buttons->[1]);
    # print Dumper($buttons);

    }
    # exit 0;

    for (my $i = int($buttons->[0]->{max}+10000); $i > int($buttons->[0]->{max}-10000); $i--)
    {
        # print "Checking: $i\n";
        my $x = $prize->{x} - ($i * $buttons->[0]->{x});
        my $y = $prize->{y} - ($i * $buttons->[0]->{y});
        # print "Checking: $x, $y\n";
        if ($x < 0 || $y < 0)
        {
            next;
        }

        # print "Checking: $x, $y\n";
        # print $x % $buttons->[0]->{x} . " " . $y % $buttons->[0]->{y} . "\n";

        if ($x % $buttons->[1]->{x} == 0 && $y % $buttons->[1]->{y} == 0)
        {
            my $a = $x / $buttons->[1]->{x};
            my $b = $y / $buttons->[1]->{y};

            # print "Found: $a, $b\n";
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

    my $a = $x / $primary->{x};
    my $b = $y / $primary->{y};

    # print "Checking: $x, $y\n";


    # print "Found: $a, $b\n";

    my $max_x = ($target->{x} - ($secondary->{min} * $secondary->{x})) / $primary->{x};
    my $max_y = ($target->{y} - ($secondary->{min} * $secondary->{y})) / $primary->{y};

    my $max = min($max_x, $max_y);

    if (int($primary->{max}) == int($max))
    {
        return 0;
    }

    $primary->{max} = min($max_x, $max_y);

    # print "Max: $primary->{max}\n";

    # print "($target->{y} - ($secondary->{min} * $secondary->{y})) / $primary->{y}\n";
    # my $max = ($target->{y} - ($secondary->{min} * $secondary->{y})) / $primary->{y};
    # my $max_y = ($target->{y} - ($secondary->{min} * $secondary->{y})) / $primary->{y};

    # print "Max: $max_x, $max_y\n";
    # my $max = $max_x > $max_y ? $max_x : $max_y;
    # print "Max: $max\n";

    # if (int($primary->{max}) == int($max))
    # {
    #     print int($primary->{max}) . " == " . int($max) . "\n";
    #     return 0;
    # }

    # $primary->{max} = $max;

    return 1;
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

    my $min = min($min_x, $min_y);

    # if (int($primary->{min}) == int($min))
    # {
    #     return 0;
    # }

    $primary->{min} = max($min_x, $min_y);

    # print "Min: $primary->{min}\n";

    # print "($target->{x} - ($secondary->{max} * $secondary->{y})) / $primary->{x}\n";
    # my $min_x = ($target->{x} - ($secondary->{max} * $secondary->{y})) / $primary->{x};
    # my $min = ($target->{x} - ($secondary->{max} * $secondary->{y})) / $primary->{x};

    # print "Min: $min_x, $min_y\n";
    # my $min = $min_x < $min_y ? $min_x : $min_y;

    # print "Min: $min\n";

    # $primary->{min} = $min;
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
