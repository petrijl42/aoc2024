#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $filename = "input2.txt";

    my $codes = read_codes($filename);
    my $complexity = get_complexity($codes);

    print "Complexity: $complexity\n";
}

sub read_codes
{
    my $filename = shift;

    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my @codes;

    while (my $line = <$fd>)
    {
        chomp $line;
        push @codes, [ split(//, $line) ];
    }

    close $fd;

    return \@codes;
}

sub get_complexity
{
    my $codes = shift;

    my $numeric_keypad = get_numeric_keypad();
    my $directional_keypad = get_directional_keypad();

    my @keypads;
    push @keypads, $numeric_keypad;
    push @keypads, $directional_keypad for (1..25);

    my $total = 0;
    my $cache = {};
    foreach my $code (@$codes)
    {
        my $count = get_minimum_move_count($code, \@keypads, 0, $cache);
        $total += $count * code_to_number($code);
    }

    return $total;
}

sub code_to_number
{
    my $code = shift;

    my $number = 0;

    for my $digit (@$code)
    {
        if ($digit =~ /^[0-9]$/)
        {
            $number = $number * 10 + $digit;
        }
    }

    return $number;
}

sub get_minimum_move_count
{
    my $buttons = shift;
    my $keypads = shift;
    my $pad = shift;
    my $cache = shift;

    my $count = 0;

    my $str = join("", @$buttons);
    if (exists $cache->{$pad}->{$str})
    {
        return $cache->{$pad}->{$str};
    }

    my $current = $keypads->[$pad]->{'A'};

    my $not_valid = {};
    my $x = $keypads->[$pad]->{'X'}->{x};
    my $y = $keypads->[$pad]->{'X'}->{y};
    $not_valid->{ $x }->{ $y } = 1;

    foreach my $button (@$buttons)
    {
        my $destination = $keypads->[$pad]->{$button};
        my $paths = get_paths($current, $destination, $not_valid);
        my $min;

        foreach my $path (@$paths)
        {
            push @$path, 'A';
            my $value;
            if (@$keypads > $pad + 1)
            {
                $value = get_minimum_move_count($path, $keypads, $pad + 1, $cache);
            }
            else
            {
                $value = scalar(@$path);
            }

            if (!defined $min || $value < $min)
            {
                $min = $value;
            }
        }

        $count += $min;
        $current = $destination;
    }

    $cache->{$pad}->{$str} = $count;

    return $count;
}

sub get_numeric_keypad
{
    my $numpad = [
        ['7', '8', '9'],
        ['4', '5', '6'],
        ['1', '2', '3'],
        ['X', '0', 'A']
    ];

    my %hash;

    for (my $y = 0; $y < scalar @$numpad; $y++)
    {
        for (my $x = 0; $x < scalar @{$numpad->[$y]}; $x++)
        {
            $hash{$numpad->[$y][$x]} = { x => $x, y => $y };
        }
    }

    return \%hash;
}

sub get_directional_keypad
{
    my $numpad = [
        ['X', '^', 'A'],
        ['<', 'v', '>']
    ];

    my %hash;

    for (my $y = 0; $y < scalar @$numpad; $y++)
    {
        for (my $x = 0; $x < scalar @{$numpad->[$y]}; $x++)
        {
            $hash{$numpad->[$y][$x]} = { x => $x, y => $y };
        }
    }

    return \%hash;
}

sub get_paths
{
    my $start = shift;
    my $end = shift;
    my $not_valid = shift;

    my @paths;

    my $dx = $end->{"x"} - $start->{"x"};
    my $dy = $end->{"y"} - $start->{"y"};

    if ($dx != 0 || $dy != 0)
    {
        my @directions;
        push @directions, { "x" => $dx / abs($dx), "y" =>  0 } if ($dx != 0);
        push @directions, { "y" => $dy / abs($dy), "x" =>  0 } if ($dy != 0);

        foreach my $direction (@directions)
        {
            my $x = $start->{"x"} + $direction->{"x"};
            my $y = $start->{"y"} + $direction->{"y"};

            next if ($not_valid->{$x}->{$y});

            my $new_start = { "x" => $x, "y" => $y };
            my $new_paths = get_paths($new_start, $end, $not_valid);
            foreach my $path (@$new_paths)
            {
                unshift @$path, get_direction_character($direction);
                push @paths, $path;
            }

        }
    }
    elsif ($dx == 0 && $dy == 0)
    {
        push @paths, [];
    }

    return \@paths;
}

sub get_direction_character
{
    my $direction = shift;

    if ($direction->{"x"} == 0 && $direction->{"y"} > 0)
    {
        return "v";
    }
    elsif ($direction->{"x"} == 0 && $direction->{"y"} < 0)
    {
        return "^";
    }
    elsif ($direction->{"x"} > 0 && $direction->{"y"} == 0)
    {
        return ">";
    }
    elsif ($direction->{"x"} < 0 && $direction->{"y"} == 0)
    {
        return "<";
    }
    else
    {
        die "Invalid direction";
    }
}
