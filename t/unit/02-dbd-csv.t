#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use DBIx::XHTML_Table;
use Test::More;

eval "use DBD::CSV";
plan skip_all => "DBD::CSV required" if $@;
plan tests => 2;

my $dbh = DBI->connect ("dbi:CSV:", undef, undef, {
    f_ext      => ".csv/r",
    f_dir      => "t/data",
    RaiseError => 1,
});

my $table = new_ok 'DBIx::XHTML_Table', [ $dbh ];
$table->exec_query ("select * from test");
is $table->output( { no_indent => 1 } ),
    '<table><thead><tr><th>Id</th><th>Name</th><th>Description</th></tr></thead><tbody><tr><td>1</td><td>plain</td><td>plain text</td></tr><tr><td>2</td><td>html</td><td>&lt;html&gt;some text&lt;/html&gt;</td></tr><tr><td>3</td><td>encoded</td><td>&amp;lt;html&amp;gt;some text&amp;lt;/html&amp;gt;</td></tr></tbody></table>',
    "correct output from CSV file"
;
