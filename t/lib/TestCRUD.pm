package TestCRUD;
use Dancer ':syntax';

our $VERSION = '0.01';

use Dancer::Plugin::SimpleCRUD;
use Dancer::Plugin::Database;

# insert data into our database
my @sql = (
    q/create table test_table (id INTEGER, name VARCHAR, category VARCHAR)/,
    q/insert into test_table values (1, 'sukria', 'admin')/,
    q/insert into test_table values (2, 'bigpresh', 'admin')/,
    q/insert into test_table values (3, 'badger', 'animal')/,
    q/insert into test_table values (4, 'bodger', 'man')/,
    q/insert into test_table values (5, 'mousey', 'animal')/,
    q/insert into test_table values (6, 'mystery2', null)/,
    q/insert into test_table values (7, 'mystery1', null)/,
);
print "CREATING SQL DATA\n";
database->do($_) for @sql;

# set up simple_crud routes
simple_crud(
    prefix => "/test_table",
    db_table => "test_table",
    record_title => "test_table",
    editable => 0,
);

