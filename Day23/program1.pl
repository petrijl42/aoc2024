#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $connections = read_connections("input2.txt");
    my $groups = get_groups($connections);

    print "Groups: $groups\n";
}

sub read_connections
{
    my $filename = shift;

        my $fd;

    open($fd, "<", $filename) or die "Could not open input for reading";

    my %connections;

    while (my $line = <$fd>)
    {
        chomp $line;

        my ($a, $b) = split /-/, $line;
        push @{$connections{$a}}, $b;
        push @{$connections{$b}}, $a;
    }

    close $fd;

    return \%connections;
}

sub get_groups
{
    my $connections = shift;

    my %groups;
    foreach my $computer (keys %$connections)
    {
        # print "Computer: $computer\n";
        # print "Connections: @{$connections->{$computer}}\n";
        my $neighbours = $connections->{$computer};

        for (my $i = 0; $i < scalar @$neighbours; $i++)
        {
            for (my $j = 0; $j < scalar @$neighbours; $j++)
            {
                next if $i == $j;
                my $a = $neighbours->[$i];
                my $b = $neighbours->[$j];

                next unless ((index $computer, 't') == 0) || ((index $a, 't') == 0) || ((index $b, 't') == 0);

                if ($connections->{$a} && grep { $_ eq $b } @{$connections->{$a}})
                {
                    my $str = join ",", sort ($computer, $a, $b);
                    $groups{$str} = 1;
                }
            }
        }
    }

    # foreach my $group (keys %groups)
    # {
    #     print "$group\n";
    # }

    return scalar keys %groups;
}
