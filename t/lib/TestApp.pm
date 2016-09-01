package t::lib::TestApp;

# verbatim from dpd, except lines at very end
use Dancer;
use Dancer::Plugin::Database;
#use Test::More; # for use_ok
use Test::More import => ['!pass']; # import avoids 'prototype mismatch' with Dancer
use File::Temp qw(tmpnam);

no warnings 'uninitialized';

my $db_filename = File::Temp::tmpnam();
print "db_filename is $db_filename\n";

config->{plugins}{Database}{driver} = "SQLite";
config->{plugins}{Database}{database} = $db_filename;

BEGIN {
    use_ok( 'Dancer::Plugin::SimpleCRUD' ) || die "Can't load Dancer::Plugin::SimpleCrud. Bail out!\n";
}
my @sql = (
    q/create table users (id INTEGER, name VARCHAR, category VARCHAR)/,
    q/insert into users values (1, 'sukria', 'admin')/,
    q/insert into users values (2, 'bigpresh', 'admin')/,
    q/insert into users values (3, 'badger', 'animal')/,
    q/insert into users values (4, 'bodger', 'man')/,
    q/insert into users values (5, 'mousey', 'animal')/,
    q/insert into users values (6, 'mystery2', null)/,
    q/insert into users values (7, 'mystery1', null)/,
);

database->do($_) for @sql;

# At the very end, add  simple_crud test
simple_crud(
    record_title => 'Users',
    prefix => '/users',
    db_table => 'user',
    editable => 1,
);
1;
