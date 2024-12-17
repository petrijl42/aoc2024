#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $input = read_input('input2.txt');
    my $output = run_program($input);

    print "Output: $output\n";
}

sub read_input
{
    my $filename = shift;
    my $fd;
    open($fd, "<", $filename) or die "Could not open input for reading";

    my $registers = {};
    my $instructions;

    while (my $line = <$fd>)
    {
        chomp $line;

        next if ($line eq '');

        if ($line =~ /Register ([ABC]): (\d+)/)
        {
            $registers->{$1} = int($2);
        }
        elsif ($line =~ /Program: ([\d,]+)/)
        {
            $instructions = [split(/,/, $1)];
        }

    }

    close($fd);

    return { registers => $registers, instructions => $instructions };
}

sub run_program
{
    my $input = shift;
    my $registers = $input->{registers};
    my $instructions = $input->{instructions};

    my @output;
    my $ip = 0;

    while ($ip < scalar(@$instructions))
    {
        my $instruction = $instructions->[$ip];

        # print_machine_state($registers, $ip);

        if ($instruction == 0)
        {
            my $operand = get_combo_operand($instructions->[$ip + 1], $registers);
            $registers->{A} = int($registers->{A} / (2 ** $operand));
        }
        elsif ($instruction == 1)
        {
            my $operand = $instructions->[$ip + 1];
            $registers->{B} = int($registers->{B} ^ $operand);
        }
        elsif ($instruction == 2)
        {
            my $operand = get_combo_operand($instructions->[$ip + 1], $registers);
            $registers->{B} = int($operand % 8);
        }
        elsif ($instruction == 3)
        {
            if ($registers->{A} != 0)
            {
                my $operand = $instructions->[$ip + 1];
                $ip = $operand;
                next;
            }
        }
        elsif ($instruction == 4)
        {
            $registers->{B} = int($registers->{B} ^ $registers->{C});
        }
        elsif ($instruction == 5)
        {
            my $operand = get_combo_operand($instructions->[$ip + 1], $registers);
            push @output, ($operand % 8);
        }
        elsif ($instruction == 6)
        {
            my $operand = get_combo_operand($instructions->[$ip + 1], $registers);
            $registers->{B} = int($registers->{A} / (2 ** $operand));
        }
        elsif ($instruction == 7)
        {
            my $operand = get_combo_operand($instructions->[$ip + 1], $registers);
            $registers->{C} = int($registers->{A} / (2 ** $operand));
        }
        else
        {
            die "Unknown instruction $instruction\n";
        }

        $ip += 2;
    }

    # print_machine_state($registers, $ip);

    return join(',', @output);
}

sub get_combo_operand
{
    my $operand = shift;
    my $registers = shift;

    # print "Getting operand $operand\n";

    if ($operand >= 0 && $operand <= 3)
    {
        return $operand;
    }
    if ($operand == 4)
    {
        return $registers->{A};
    }
    elsif ($operand == 5)
    {
        return $registers->{B};
    }
    elsif ($operand == 6)
    {
        return $registers->{C};
    }
    else
    {
        die "Invalid program reserved operand.\n";
    }
}

sub print_machine_state
{
    my $registers = shift;
    my $ip = shift;

    print "Registers: A=$registers->{A}, B=$registers->{B}, C=$registers->{C}\n";
    print "Instruction Pointer: $ip\n";
}
