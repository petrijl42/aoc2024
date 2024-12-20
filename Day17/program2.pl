#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $input = read_input('input2.txt');

    my $instructions = $input->{instructions};
    my $a = iterate_value($instructions, 0, scalar(@$instructions));

    print "A: $a\n";

    my $registers = { A => $a, B => 0, C => 0 };
    my $output = run_program($registers, $instructions, 0);

    print "Program: $input->{program}\n";
    print "Output:  " . join(',', @$output) . "\n";
}

sub iterate_value
{
    my $program = shift;
    my $value = shift;
    my $digit = shift;

    if ($digit <= 0)
    {
        return $value;
    }

    foreach my $i (0..7)
    {
        my $new_value = ($value << 3) + $i;

        my $registers = { A => $new_value, B => 0, C => 0 };
        my $output = run_program($registers, $program);

        if ($output->[0] == $program->[$digit - 1])
        {
            my $result = iterate_value($program, $new_value, $digit - 1);

            if (defined $result)
            {
                return $result;
            }
        }
    }

    return undef;
}

sub read_input
{
    my $filename = shift;
    my $fd;
    open($fd, "<", $filename) or die "Could not open input for reading";

    my $registers = {};
    my $instructions;
    my $program;

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
            $program = $1;
            $instructions = [split(/,/, $program)];
        }

    }

    close($fd);

    return { registers => $registers, instructions => $instructions, program => $program };
}

sub run_program
{
    my $registers = shift;
    my $instructions = shift;

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

    return \@output;
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
