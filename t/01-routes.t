#!perl 

use Test::More;

use Dancer qw(:syntax :tests);
use Dancer::Test;
use File::Temp;

use FindBin qw($Bin);
use lib "$Bin/lib";	#
my $filename = File::Temp->new(UNLINK=>1);    # will be automatically unlinked. Set to 0 to keep.

config->{plugins}{Database}{driver} = "CSV";
config->{plugins}{Database}{database} = $filename;
use_ok( 'TestCRUD' ) || die "Can't load test module TestCRUD";

route_exists [ GET => '/test_table' ];
response_status_isnt [GET => '/test_table'], 404, "response for GET /test_table is not a 404";

done_testing();


