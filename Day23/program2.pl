#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $connections = read_connections("input2.txt");
    my $lan = get_largest_lan($connections);

    print "LAN: " . join(",", sort keys %$lan) . "\n";
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

sub get_largest_lan
{
    my $connections = shift;

    my $max = 0;
    my $largest_lan;

    foreach my $computer (keys %$connections)
    {
        my $lan = get_most_connected($connections, {}, $computer);
        # print join(", ", sort keys %$lan) . "\n";

        if (scalar(keys %$lan) > $max)
        {
            $max = scalar(keys %$lan);
            $largest_lan = $lan;
        }
    }

    return $largest_lan;
}

sub get_most_connected
{
    my $connections = shift;
    my $nodes = shift;
    my $computer = shift;

    my $max = 0;
    my $max_connected = $nodes;

    $nodes->{$computer} = 1;

    # print join(", ", sort keys %$nodes) . "\n";

    foreach my $node (@{$connections->{$computer}})
    {
        if (exists $max_connected->{$node})
        {
            next;
        }

        next unless is_connected($connections, $nodes, $node);

        my $lan = get_most_connected($connections, { %$nodes }, $node);

        next if not defined $lan;

        # print join(", ", sort keys %$nodes) . "\n";

        if ((not defined $max_connected) || scalar(keys %$lan) > $max)
        {
            $max = scalar(keys %$lan);
            $max_connected = $lan;
        }
    }

    return $max_connected;
}

sub is_connected
{
    my $connections = shift;
    my $nodes = shift;
    my $node = shift;

    foreach my $old (keys %$nodes)
    {
        if (not grep { $_ eq $old } @{$connections->{$node}})
        {
            return 0;
        }
    }

    return 1;
}