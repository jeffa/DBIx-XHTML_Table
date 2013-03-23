# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..14\n"; }
END {print "not ok 1\n" unless $loaded;}

use vars qw($loaded);
$loaded = 1;

use strict;
use DBIx::XHTML_Table;

my $ok;
tie $ok, 'Tie::Scalar::OK';

print $ok = $loaded;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
sub get_table {
	return DBIx::XHTML_Table->new([ 
		[ qw(h1 h2) ],
		[ qw(foo 1) ],
		[ qw(bar 2) ],
	]);
}

# table creation
my $table;
eval { $table = get_table() };
print $ok = $table;

# table output
print $ok = ($table->output =~ /<th>H1<\/th>/);
print $ok = ($table->output =~ /<td>foo<\/td>/);


# modify
$table->modify(td=>{a=>'b'},'h1');
print $ok = ($table->output =~ /<td a="b">foo<\/td>/);
print $ok = ($table->output !~ /<td a="b">1<\/td>/);

print $ok = ($table->output({no_ucfirst => 1}) =~ /<th>h1<\/th>/);

# two map heads - notice that ucfirst
$table->map_head(sub{my$x=shift;$x=~s/h/z/;return$x},'h1');
print $ok = ($table->output =~ /<th>z1<\/th>/);
print $ok = ($table->output !~ /<th>H1<\/th>/);

$table->map_head(sub{my$x=shift;$x=~s/h2/foo/;return$x},'h2');
print $ok = ($table->output =~ /<th>foo<\/th>/);
print $ok = ($table->output !~ /<th>H2<\/th>/);


#print $table->output;


# these have irrevocal effects ... ??
print $ok = ($table->output({no_head    => 1}) !~ /<th>H1<\/th>/);
print $ok = ($table->output({no_indent  => 1}) !~ /\n|\t/);


# test connect
print "Test database? [n] ";
if (<> =~ /y/i) {
	my @creds = 'DBI';

	foreach (qw(vendor database host user pass)) {
		print ucfirst $_, ': ';
		#print '(i.e. mysql) ' if /vendor/;
		my $ans = <>;
		push @creds, $ans;
	}
	chomp @creds;

	my $xt;
	eval {$xt = DBIx::XHTML_Table->new(join(':',@creds[0..3]),@creds[4,5])};
	print $ok = $xt;
}

package Tie::Scalar::OK;

sub TIESCALAR {
	my $class = shift;
	my $self  = {
		i  => 0,
		ok => '',
	};
	return bless $self, $class;
}

sub STORE {
	my ($self,$ok) = @_;
	$self->{ok} = $ok ? 'ok' : 'not ok';
	$self->{i}++;
}

sub FETCH {
	my ($self) = @_;
	return "$self->{ok} $self->{i}\n";
}

sub DESTROY {}
