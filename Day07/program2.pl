#!/usr/bin/perl -w

use strict;

my $fd;

open ($fd, '<', "input2.txt") || die 'Could not open input for reading';

my @operators = ('+', '*', '|');
my $data = ();

while (my $line = <$fd>)
{
    $line =~ s/\n//;

    if ($line =~ /^(\d+): ([\d\s]+)$/)
    {
        my $total = $1;
        my $values = $2;

        my @values = split /\s+/, $values;

        push @{$data}, { total => $total, values => \@values };
    }
    else
    {
        die "Invalid line: $line\n";
    }
}

close $fd;

my $result = 0;

foreach my $equation (@{$data})
{
    my $total = $equation->{total};
    my $values = $equation->{values};

    if (evaluate_equation($total, $values, \@operators))
    {
        $result += $total
    }
}

print "Total result: $result\n";

sub evaluate_equation
{
    my $total = shift;
    my $values = shift;
    my $operators = shift;

    my $state = get_start_state(int(@{$values}) - 1);

    do
    {
        my $calculated_total = calculate_total($values, $operators, $state);

        if ($calculated_total == $total)
        {
            return 1;
        }

    } while (increment_state($state, int(@{$operators})));

    return 0;
}

sub print_state
{
    my $state = shift;

    print join(", ", @{$state}) . "\n";
}

sub calculate_total
{
    my $values = shift;
    my $operators = shift;
    my $state = shift;
    my $total = 0;

    my $index = 0;
    $total = $values->[$index];

    foreach my $op (@{$state})
    {
        $index++;
        $total = perform_calculation($total, $values->[$index], $operators->[$op]);
    }
    return $total;
}

sub perform_calculation
{
    my $first = shift;
    my $second = shift;
    my $operator = shift;

    if ($operator eq '+')
    {
        return $first + $second;
    }
    elsif ($operator eq '*')
    {
        return $first * $second;
    }
    elsif ($operator eq '|')
    {
        return $first . $second;
    }
    else
    {
        die "Invalid operator: $operator\n";
    }
}

sub get_start_state
{
    my $size = shift;

    my @start_state = split //, '0' x $size;

    return \@start_state;
}

sub increment_state
{
    my $state = shift;
    my $base = shift;

    for (my $i = int(@{$state}) - 1; $i >= 0; $i--)
    {
        if ($state->[$i] < $base - 1)
        {
            $state->[$i]++;
            return 1;
        }
        else
        {
            $state->[$i] = 0;
        }
    }

    return 0;
}