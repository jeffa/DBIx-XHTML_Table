#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More;
use Data::Dumper;
use DBIx::XHTML_Table;

eval "use HTML::TableExtract";
plan skip_all => "HTML::TableExtract required" if $@;

plan tests => 6;

{   # no mixed case duplicates
    my @headers = qw(HD_onE HD_twO HD_threE );
    my @data    = ( [@headers], ([ ('x') x @headers ]) x 4 );

    my $table = DBIx::XHTML_Table->new( [@data] );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_two Hd_three)],     "default header modifications";

    $table->map_head( sub { lc shift } );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_two hd_three)],     "all headers changed";

    $table->map_head( sub { uc shift }, 2 );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_two HD_THREE)],     "header changed by col index";

    $table->map_head( sub { uc shift }, qw(hd_two) );
    is_deeply extract( $table, 0 ), [qw(hd_one HD_TWO HD_THREE)],     "header changed by lowercased col key";

    $table->map_head( sub { lc shift }, qw(hd_TWo) );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_two HD_THREE)],     "header changed by matched col key";

SKIP: {
    skip "keys are mangled", 1;
    $table->map_head( sub { lc( ucfirst shift ) }, qw(HD_twO) );
    is_deeply extract( $table, 0 ), [qw(hd_one hD_TWO HD_THREE)],     "header changed by exact col key";
};
}

exit;
sub extract {
    my ($table,$row,$col) = @_;
    my $extract = HTML::TableExtract->new( keep_headers => 1 );
    $extract->parse( $table->output );
    if (defined $row) {
        return @{[ $extract->rows ]}[$row];
    } elsif (defined $col) {
        # TODO: if needed
    } else {
        return $extract->rows;
    }
}
