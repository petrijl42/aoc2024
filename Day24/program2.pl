#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $input = read_input("input2.txt");
    show($input->{op}, $input->{gates});
}

sub read_input
{
    my $filename = shift;

    my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my %values;
    my %gates;
    my %op;

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
            $gates{$4} = { type => $2, inputs => [$1, $3], output => $4 };

            $op{$1}->{$3}->{$2} = $4;
            $op{$3}->{$1}->{$2} = $4;
        }
        else
        {
            die "Invalid line: $line";
        }
    }

    close $fd;

    return { values => \%values, gates => \%gates, op => \%op };
}

sub show
{
    my $op = shift;
    my $gates = shift;

    my $prev;

    for (my $i = 0; $i < 44; $i++)
    {
        my $a = "x" . sprintf("%02d", $i);
        my $b = "y" . sprintf("%02d", $i);
        my $c = "z" . sprintf("%02d", $i);

        print "$a $b\n";

        if (not defined $prev)
        {
            my $result = $op->{$a}->{$b}->{XOR};
            $prev = $op->{$a}->{$b}->{AND};

            print "  $a XOR $b -> $result\n";
            print "  $a AND $b -> $prev\n";
            print "Result: $result\n";
            print "Prev: $prev\n";
        }
        else
        {
            my $tmp1 = $op->{$a}->{$b}->{AND};
            my $tmp2 = $op->{$a}->{$b}->{XOR};
            my $tmp3 = $op->{$tmp2}->{$prev}->{AND};
            my $result = $op->{$tmp2}->{$prev}->{XOR};
            $prev = $op->{$tmp1}->{$tmp3}->{OR};

            print "  $a AND $b -> $tmp1\n";
            print_operations($op, $tmp1, 4);
            print "  $a XOR $b -> $tmp2\n";
            print_operations($op, $tmp2, 4);
            print "tmp1: $tmp1\n";
            print "tmp2: $tmp2\n";
            print "tmp3: $tmp3\n";
            print "prev: $prev\n";
            print "Result: $result\n";
        }

        print "\n";

    }
}

sub print_operations
{
    my $ops = shift;
    my $name = shift;
    my $indent = shift;

    foreach my $key (sort keys %{$ops->{$name}})
    {
        foreach my $key2 (sort keys %{$ops->{$name}->{$key}})
        {
            print " " x $indent . "$name $key $key2 -> $ops->{$name}->{$key}->{$key2}\n";

        }
    }
}
