#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $input = read_input("input2.txt");
    my $value = calculate_value($input);

    print "Value: $value\n";
}

sub read_input
{
    my $filename = shift;

    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my %values;
    my @gates;

    while (my $line = <$fd>)
    {
        chomp $line;

        next if $line eq "";

        if ($line =~ /^(\w+): ([01])$/)
        {
            $values{$1} = $2;
        }
        elsif ($line =~ /^(\w+) (AND|XOR|OR) (\w+) -> (\w+)$/)
        {
            push @gates, { type => $2, inputs => [$1, $3], output => $4 };
        }
        else
        {
            die "Invalid line: $line";
        }
    }

    close $fd;

    return { values => \%values, gates => \@gates };
}

sub calculate_value
{
    my $input = shift;

    my %values = %{$input->{values}};
    my @gates = @{$input->{gates}};

    while (scalar @gates > 0)
    {
        my $gate = shift @gates;

        my $a = $values{$gate->{inputs}->[0]};
        my $b = $values{$gate->{inputs}->[1]};

        if ((not defined $a) || (not defined $b))
        {
            push @gates, $gate;
            next;
        }

        # print "Gate: $gate->{inputs}->[0] = $a, $gate->{inputs}->[1] = $b, $gate->{type}, $gate->{output}\n";
        $values{$gate->{output}} = get_gate_value($a, $b, $gate->{type});

    }

    return get_result(\%values);
}

sub get_gate_value
{
    my $a = shift;
    my $b = shift;
    my $type = shift;

    if ($type eq "AND")
    {
        return 1 if ($a and $b);
        return 0;
    }
    elsif ($type eq "XOR")
    {

        return 1 if ($a xor $b);
        return 0;
    }
    elsif ($type eq "OR")
    {
        return 1 if ($a or $b);
        return 0;
    }
    else
    {
        die "Invalid gate type: $type";
    }
}

sub get_result
{
    my $values = shift;

    my $result = "0b";

    foreach my $key (sort { $b cmp $a } keys %$values)
    {
        if ($key =~ /^z/)
        {
            $result .= $values->{$key};
        }
    }

    return oct $result;
}