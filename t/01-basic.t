use strict;
use warnings;

use Test::More import => ['!pass'];
use t::lib::TestApp;
use Dancer ':syntax';
use Dancer::Plugin::SimpleCRUD;

my $dancer_version;
BEGIN {
    $dancer_version = (exists &dancer_version) ? int(dancer_version()) : 1;
    require Dancer::Test;
    if ($dancer_version == 1) {
        Dancer::Test->import();
    } else {
        Dancer::Test->import('t::lib::TestApp');
    }
}



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
                         handle_class => 'TestHandleClass',
                        }
           };



set plugins => $conf;
set logger => 'capture';
set log => 'debug';



diag sprintf "Testing DPSC version %s under Dancer %s",
    $Dancer::Plugin::SimpleCRUD::VERSION,
    $Dancer::VERSION;

response_content_is   [ GET => '/connecthookfired' ], 1,
    'database_connected hook fires';

response_content_is   [ GET => '/errorhookfired' ], 1,
    'database_error hook fires';

response_status_is    [ GET => '/prepare_db' ], 200, 'db is created';

response_status_is [GET => '/'], 200, "response for GET / is 200";

done_testing();

