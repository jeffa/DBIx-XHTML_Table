use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'DBIx::XHTML_Table',
    AUTHOR           => q{jeffa <info+cpan@unlocalhost.com>},
    VERSION_FROM     => 'lib/DBIx/XHTML_Table.pm',
    ABSTRACT_FROM    => 'lib/DBIx/XHTML_Table.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'DBI'        => 0,
        'Test::More' => 0,
    },
    PREREQ_PM => { },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'DBIx-XHTML_Table-*' },
);

# replace standard test harness with our own when 'make test' is invoked
# this is the only way i know to force 'make test' to run recursively
package MY;
sub test {
    my $inherited = shift->SUPER::test(@_);
    # replace line *after* with our script -----V
    $inherited =~ s{(test_dynamic :: pure_all\n).*\n}{$1\tprove -lrv\n}m;
    return $inherited;
}
