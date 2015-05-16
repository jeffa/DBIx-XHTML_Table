#!perl -T
use strict;
use warnings FATAL => 'all';
use DBIx::XHTML_Table;
use Test::More tests => 6;

my $attr = { no_indent => 1 };

my $table = new_ok 'DBIx::XHTML_Table', [[ [0,1], [1,1], [2,2] ]];
is $table->output( $attr ),
    '<table><thead><tr><th>0</th><th>1</th></tr></thead><tbody><tr><td>1</td><td>1</td></tr><tr><td>2</td><td>2</td></tr></tbody></table>',
    'rows with headers of 0 and 1',
;

$table->modify( td => { a => 'b' }, [ 1 ] );
is $table->output( $attr ),
    '<table><thead><tr><th>0</th><th>1</th></tr></thead><tbody><tr><td>1</td><td a="b">1</td></tr><tr><td>2</td><td a="b">2</td></tr></tbody></table>',
    'modify() works on 1',
;


$table = new_ok 'DBIx::XHTML_Table', [[ [0,1], [1,1], [2,2] ]];
is $table->output( $attr ),
    '<table><thead><tr><th>0</th><th>1</th></tr></thead><tbody><tr><td>1</td><td>1</td></tr><tr><td>2</td><td>2</td></tr></tbody></table>',
    'reset table',
;

$table->modify( td => { a => 'b' }, [ 0 ] );
is $table->output( $attr ),
    '<table><thead><tr><th>0</th><th>1</th></tr></thead><tbody><tr><td a="b">1</td><td>1</td></tr><tr><td a="b">2</td><td>2</td></tr></tbody></table>',
    'modify() works on 0',
;

__DATA__
#11681 Possible problem with modify() on column number 0
