#!perl -T
use strict;
use warnings FATAL => 'all';
use DBIx::XHTML_Table;
use Test::More tests => 3;

my $attr = { no_indent => 1 };

my $table = new_ok 'DBIx::XHTML_Table', [[ ['<"&>'], ['<"&>'] ]];
is $table->output( $attr ),
    '<table><thead><tr><th>&lt;&quot;&amp;&gt;</th></tr></thead><tbody><tr><td>&lt;&quot;&amp;&gt;</td></tr></tbody></table>',
    'escape XML entities',
;

$table->map_head( sub{ 'new' }, '<"&>' );
is $table->output( $attr ),
    '<table><thead><tr><th>new</th></tr></thead><tbody><tr><td>&lt;&quot;&amp;&gt;</td></tr></tbody></table>',
    'headers retain orig values',
;

__DATA__
#21761 Special XML characters should be expressed as entities
