#!perl 

use Test::More;

use Dancer qw(:syntax :tests);
use Dancer::Test;
use File::Temp;

use FindBin qw($Bin);
use lib "$Bin/lib";	#
my $tmpfilename = File::Temp->new(UNLINK=>0);

ok($tmpfilename, "tmpfilename is $tmpfilename");

config->{plugins}{Database}{driver} = "CSV";
config->{plugins}{Database}{database} = $tmpfilename;

require_ok( 'TestCRUD' ) || die "Can't load test module TestCRUD";

route_exists [ GET => '/test_table' ];
response_status_is [ GET => '/test_table' ], 200, 'GET /test_table is found';

unlink($tmpfilename);

done_testing();


