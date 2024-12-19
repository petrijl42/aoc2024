#!/usr/bin/perl -w

use strict;

main();

sub main
{
    my $input = read_input("input2.txt");
    my $count = count_possible_patterns($input->{towels}, $input->{patterns});

    print "Count: $count\n";
}

sub read_input
{
    my $filename = shift;
    my $fd;
    open($fd, "<", $filename) or die "Could not open input for reading";

    my $line = <$fd>;
    chomp $line;

    my $towels = [split(/, /, $line)];

    my $patterns = [];
    while ($line = <$fd>)
    {
        chomp $line;

        next if $line eq "";

        push(@$patterns, $line);
    }

    close($fd);

    return {
        towels => $towels,
        patterns => $patterns
    };
}

sub count_possible_patterns
{
    my $towels = shift;
    my $patterns = shift;

    my $count = 0;
    foreach my $pattern (@$patterns)
    {
        # print "Pattern: $pattern\n";
        $count += possible_combinations($towels, $pattern);
    }

    return $count;
}


sub possible_combinations
{
    my $towels = shift;
    my $pattern = shift;
    my $checked = shift;

    if (!defined $checked)
    {
        $checked = {};
    }

    # print "Pattern: $pattern\n";

    return $checked->{$pattern} if defined $checked->{$pattern};

    my $count = 0;

    foreach my $towel (@$towels)
    {
        if ($towel eq $pattern)
        {
            $count++;
            next;
        }

        next if length($towel) > length($pattern);

        my $part = substr($pattern, 0, length($towel));

        if ($towel eq $part)
        {
            my $rest = substr($pattern, length($towel));
            $count += possible_combinations($towels, $rest, $checked);
        }
    }

    $checked->{$pattern} = $count;

    return $count;
}
