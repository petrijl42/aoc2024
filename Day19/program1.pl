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
        if (is_possible_pattern($towels, $pattern))
        {
            $count++;
        }
    }

    return $count;
}

sub is_possible_pattern
{
    my $towels = shift;
    my $pattern = shift;
    my $checked = shift;

    if (!defined $checked)
    {
        $checked = {};
    }

    # print "Pattern: $pattern\n";

    return 0 if $checked->{$pattern};

    foreach my $towel (@$towels)
    {
        if ($towel eq $pattern)
        {
            return 1;
        }

        next if length($towel) > length($pattern);

        my $part = substr($pattern, 0, length($towel));

        if ($towel eq $part)
        {
            my $rest = substr($pattern, length($towel));
            if (is_possible_pattern($towels, $rest, $checked))
            {
                return 1;
            }
        }
    }

    $checked->{$pattern} = 1;

    return 0;
}
