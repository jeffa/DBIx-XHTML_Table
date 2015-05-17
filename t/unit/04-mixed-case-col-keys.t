#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More;
use Data::Dumper;
use DBIx::XHTML_Table;

eval "use HTML::TableExtract";
plan skip_all => "HTML::TableExtract required" if $@;

plan tests => 12;

my ( $table, @headers, @data );

{   # no mixed case duplicates
    @headers = qw(HD_onE HD_twO hd_three );
    @data    = ( [@headers], ([ ('x') x @headers ]) x 3 );

    $table = DBIx::XHTML_Table->new( [@data] );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_two Hd_three)],     "default header modifications";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { lc shift } );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_two hd_three)],     "all headers changed";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { uc shift }, 2 );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_two HD_THREE)],     "header changed by col index";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { lc shift }, qw(HD_three) );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_two hd_three)],     "mixed-case query matched by lowercased col key";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { uc shift }, qw(hd_TWo) );
    is_deeply extract( $table, 0 ), [qw(Hd_one HD_TWO Hd_three)],     "mixed-case query mtcahed by col key search";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { lcfirst( uc( shift ) ) }, qw(HD_twO) );
    is_deeply extract( $table, 0 ), [qw(Hd_one hD_TWO Hd_three)],     "header changed by exact col key";
}

{   # mixed case duplicates
    @headers = qw(hd_ONE hd_one hd_TWO HD_TWO );
    @data    = ( [@headers], ([ ('x') x @headers ]) x 3 );

    $table = DBIx::XHTML_Table->new( [@data] );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_one Hd_two Hd_two)],     "default header modifications";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { lc shift } );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_one hd_two hd_two)],     "all headers changed";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { uc shift }, [ 1 ] );
    is_deeply extract( $table, 0 ), [qw(Hd_one HD_ONE Hd_two Hd_two)],     "header changed by col index";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { lc shift }, qw(HD_one) );
    is_deeply extract( $table, 0 ), [qw(Hd_one hd_one Hd_two Hd_two)],     "mixed-case query matched by lowercased col key";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { uc shift }, qw(Hd_Two) );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_one Hd_two HD_TWO)],     "mixed-case query matched by col key search";

    $table = DBIx::XHTML_Table->new( [@data] );
    $table->map_head( sub { lcfirst( uc( shift ) ) }, qw(hd_TWO) );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_one hD_TWO Hd_two)],     "header changed by exact col key";
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

# 6962 Support for mixed case field names returned by the SQL query
# promoted to a unit test :D
