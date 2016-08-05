#!perl 

use Test::More;

use Dancer qw(:syntax :tests);
use Dancer::Test;

use FindBin qw($Bin);
use lib "$Bin/lib";	#

# see http://cpansearch.perl.org/src/AMBS/Dancer-Plugin-Database-2.12/t/01-basic.t
eval { require DBD::SQLite };
if ($@) {
    plan skip_all => 'DBD::SQLite required to run these tests';
}

my $dsn = "dbi:SQLite:dbname=:memory:";
my $conf = {
            Database => {
                         dsn => $dsn,
                         connection_check_threshold => 0.1,
                         dbi_params => {
                                        RaiseError => 0,
                                        PrintError => 0,
                                        PrintWarn  => 0,
                                       },
                         handle_class => 'Dancer::Plugin::Database::Core::Handle',
                        }
           };

set plugins => $conf;
set logger => 'capture';
set log => 'debug';

use_ok( 'TestCRUD' ) || die "Can't load test module TestCRUD";

route_exists [ GET => '/test_table' ];
response_status_is [GET => '/test_table'], 200, "response for GET /test_table is 200";

done_testing();


