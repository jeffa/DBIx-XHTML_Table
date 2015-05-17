#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use DBIx::XHTML_Table;
use Test::More;
use Data::Dumper;
use FindBin qw($Bin);

plan skip_all => "must use DBIx::XHTML_Table v1.36 to generate tests"
    if $ARGV[0] && $DBIx::XHTML_Table::VERSION ne '1.36';

=for usage
Generate data files first:
    !perl % 1  

Then run tests as usual:
    !prove -vl %

It helps to generate tests on an older version prior to making
changes in the future. ;) (perlbrew can help via multiple distros)
=cut

eval "use DBD::CSV";
plan skip_all => "DBD::CSV required" if $@;

my @tests = get_tests();
plan tests => scalar( @tests ) + 1 unless @ARGV;

our $table = init_table();
my $exp_dir = "$Bin/../data/expected";

is $DBIx::XHTML_Table::VERSION, $DBIx::XHTML_Table::VERSION, "this is version $DBIx::XHTML_Table::VERSION";

for (0 .. $#tests) {
    my %args = %{ $tests[$_] };
    $args{mod_args} ||= [];
    $args{out_args} ||= {};

    my $file = sprintf( '%s/%03d-%s.md', $exp_dir, $_ + 1, $args{test} );

    # execute the modifications
    $table = init_table() unless $args{no_init};
    $args{mods}->( @{$args{mod_args}} );

    if ($ARGV[0]) {
        # generate tests
        open FH, '>', $file or die "Can't write $file: $!\n";
        print FH $DBIx::XHTML_Table::VERSION, $/;
        print FH $table->output( %{$args{out_args}} );
        print STDOUT "wrote $file\n";

    } else {
        # run tests
        open FH, $file or die "Can't read $file: $!\n";
        chomp( my $from_version = <FH> );
        my $expected = do{ local $/; <FH> };
        is $table->output( %{$args{out_args}} ), $expected, "$args{test} (generated from $from_version)";
    }

    close FH;
}

plan skip_all => "wrote tests" if @ARGV;
exit;



sub init_table {
    my $table = DBIx::XHTML_Table->new(
        DBI->connect ("dbi:CSV:", undef, undef, {
            f_ext      => ".csv/r",
            f_dir      => "$Bin/../data",
            RaiseError => 1,
        })
    );
    $table->exec_query ("select * from cookbook");
    return $table;
}
    
sub get_tests { return (
    {
        test => "no-modifications",
        mods => sub { },
    },
    {
        test => "sorted-attributes",
        mod_args => [ v => { z => 1, b => 2 }, b => { w => 5, m => 3, a => 1 } ],
        mods => sub { $table->modify( table => {@_} ) },
    },
    {
        test => "table-border",
        mod_args => [ border => 5 ],
        mods => sub { $table->modify( table => {@_} ) },
    },
    {
        test => "table-inline-css",
        mod_args => [ style => { 'border-style' => 'outset', 'border-width' => '5px' } ],
        mods => sub { $table->modify( table => {@_} ) },
    },
    {
        test => "table-and-cell-inline-css",
        mod_args => [
            { style => { 'border-style' => 'outset', 'border-width' => 'thin' } },
            { style => { 'border-style' => 'inset',  'border-width' => 'thin' } },
        ],
        mods => sub {
            $table->modify( table => $_[0] );
            $table->modify( $_ => $_[1] ) for qw(th td);
        },
    },
    {
        test => "align-th-right",
        mod_args => [ style => 'text-align: right' ],
        mods => sub { $table->modify( th => {@_} ) },
    },
    {
        test => "add-caption",
        mod_args => [],
        mods => sub { $table->modify( caption => 'Hello World' ) },
    },
    {
        test => "add-caption-css",
        mod_args => [ style => 'color: green; font-style: italic' ],
        mods => sub { $table->modify( caption => 'Hello World', {@_} ) },
    },
    {
        test => "add-caption-border",
        mod_args => [ style => { 'font-size' => 'x-large', 'border-style' => 'double' } ],
        mods => sub { $table->modify( caption => 'Hello Border', {@_} ) },
    },
    {
        test => "put-caption-at-bottom",
        mod_args => [ align => 'bottom', style => 'font-size: x-large' ],
        mods => sub { $table->modify( caption => 'Hello Border', {@_} ) },
    },
) }
