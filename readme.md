DBIx::XHTML_Table 
=================
Create HTML tables from SQL queries.

Installation
------------
[Classic CPAN installation](http://perldoc.perl.org/ExtUtils/MakeMaker.html#Default-Makefile-Behaviour):
```
perl Makefile.PL
make
make test
make install
```

Synopsis
--------
```perl
use DBIx::XHTML_Table;

# database credentials - fill in the 'blanks'
my @creds = ($data_source,$usr,$pass);

my $table = DBIx::XHTML_Table->new( @creds );
$table->exec_query(q(
    select foo from bar
    where baz='qux'
    order by foo
));

print $table->output;

# stackable method calls:
print DBIx::XHTML_Table
    ->new( @creds )
    ->exec_query( 'select foo,baz from bar' )
    ->output;
```

Documentation
-------------
* perldoc [DBIx::XHTML_Table](/lib/DBIx/XHTML_Table.pm)
* [Tutorial](http://www.unlocalhost.com/XHTML_Table/tutorial.html)
* [Cookbook](http://www.unlocalhost.com/XHTML_Table/cookbook.html)
* [FAQ](http://www.unlocalhost.com/XHTML_Table/FAQ.html)

Author
------
Jeff Anderson

License & Copyright
-------------------
See [source POD](/lib/DBIx/XHTML_Table.pm) for license and copyright information.
