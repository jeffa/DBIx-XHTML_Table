#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'DBIx::XHTML_Table' ) || print "Bail out!\n";
}

diag( "Testing DBIx::XHTML_Table $DBIx::XHTML_Table::VERSION, Perl $], $^X" );
