#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 3;

use lib 'lib';
use_ok 'DBIx::XHTML_Table';

my $attr = { no_indent => 1 };

my $table = new_ok 'DBIx::XHTML_Table', [[ ['header'], ["hello$/world"], [$/] ]];
is $table->output( $attr ),
    "<table><thead><tr><th>Header</th></tr></thead><tbody><tr><td>hello\nworld</td></tr><tr><td>&nbsp;</td></tr></tbody></table>",
    'cell with only newline',
;


__DATA__
#11666 cell data containing newlines does not render
