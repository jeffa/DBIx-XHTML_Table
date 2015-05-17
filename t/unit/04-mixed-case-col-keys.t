#!perl -T
use strict;
use warnings FATAL => 'all';
use Test::More;
use Data::Dumper;
use DBIx::XHTML_Table;

eval "use HTML::TableExtract";
plan skip_all => "HTML::TableExtract required" if $@;

plan tests => 12;

{   # no mixed case duplicates
    my @headers = qw(HD_onE HD_twO hd_three );
    my @data    = ( [@headers], ([ ('x') x @headers ]) x 3 );

    my $table = DBIx::XHTML_Table->new( [@data] );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_two Hd_three)],     "default header modifications";

    $table->map_head( sub { lc shift } );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_two hd_three)],     "all headers changed";

    $table->map_head( sub { uc shift }, 2 );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_two HD_THREE)],     "header changed by col index";

    $table->map_head( sub { lc shift }, qw(HD_three) );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_two hd_three)],     "mixed-case query matched by lowercased col key";

    $table->map_head( sub { uc shift }, qw(hd_TWo) );
    is_deeply extract( $table, 0 ), [qw(hd_one HD_TWO hd_three)],     "mixed-case query mtached by col key search";

    $table->map_head( sub { lcfirst( uc( shift ) ) }, qw(HD_twO) );
    is_deeply extract( $table, 0 ), [qw(hd_one hD_TWO hd_three)],     "header changed by exact col key";
}

{   # mixed case duplicates
    my @headers = qw(hd_ONE HD_One HD_ONE );
    my @data    = ( [@headers], ([ ('x') x @headers ]) x 3 );

    my $table = DBIx::XHTML_Table->new( [@data] );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_one Hd_one)],     "default header modifications";

    $table->map_head( sub { lc shift } );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_one hd_one)],     "all headers changed";

    $table->map_head( sub { uc shift }, [ 1 ] );
    is_deeply extract( $table, 0 ), [qw(hd_one HD_ONE hd_one)],     "header changed by col index";

}

{   # duplicates
    my @headers = qw(HD_ONE HD_ONE HD_ONE);
    my @data    = ( [@headers], ([ ('x') x @headers ]) x 3 );

    my $table = DBIx::XHTML_Table->new( [@data] );
    is_deeply extract( $table, 0 ), [qw(Hd_one Hd_one Hd_one)],     "default header modifications";

    $table->map_head( sub { lc shift } );
    is_deeply extract( $table, 0 ), [qw(hd_one hd_one hd_one)],     "all headers changed";

    SKIP: {
    skip "not sure how to deal with true dupe", 1;
    $table->map_head( sub { uc shift }, 1 );
    is_deeply extract( $table, 0 ), [qw(hd_one HD_ONE hd_one)],     "header changed by col index";
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

# 6962 Support for mixed case field names returned by the SQL query
# promoted to a unit test :D
