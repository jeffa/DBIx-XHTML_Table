#!perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use DBIx::XHTML_Table;
use Test::More;
use Data::Dumper;
use FindBin qw($Bin);

if ($ARGV[0] && $DBIx::XHTML_Table::VERSION ne '1.36') {
    plan skip_all => "must use DBIx::XHTML_Table v1.36 to generate tests";
}

=for usage
Generate tests first:
    !perl % 1  

Then run tests as usual:
    !prove -vl %

It helps to generate tests on an older version prior to making
changes in the future. ;) (perlbrew can help via multiple distros)
=cut

eval "use DBD::CSV";
plan skip_all => "DBD::CSV required" if $@;

my @tests = get_tests();
plan tests => scalar( @tests ) unless @ARGV;

our $table = init_table();
my $exp_dir = "$Bin/../data/expected";

for (0 .. $#tests) {
    my %args = %{ $tests[$_] };
    my $file = sprintf( '%s/%03d-%s.html', $exp_dir, $_ + 1, $args{test} );

    if ($ARGV[0]) {
        # generate tests
        open FH, '>', $file or die "Can't write $file: $!\n";
        $args{modifications}->( );
        print FH $table->output;
        print STDOUT "wrote $file\n";

    } else {
        # run tests
        open FH, $file or die "Can't read $file: $!\n";
        my $expected = do{ local $/; <FH> };
        $args{modifications}->();
        is $table->output, $expected, $args{test};
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
        modifications => sub { },
    },
) }


