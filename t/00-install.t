#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 2;

my $local_version = version_from_file( 'lib/DBIx/XHTML_Table.pm' );

use_ok( 'DBIx::XHTML_Table', $local_version ) or print "Bail out!\n";

is $DBIx::XHTML_Table::VERSION, $local_version, "correct version ($local_version)";

sub version_from_file {
    my $file = shift;
    open FH, $file;
    my ($version) = map {/'([0-9.]+)'/;$1} grep /our\s+\$VERSION/, <FH>;
    close FH;
    return $version;
}
