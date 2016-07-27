#!perl 

use Test::More;

use Dancer qw(:syntax :tests);
use Dancer::Test;
use File::Temp qw(tempdir);
use File::Slurp qw(write_file);

use FindBin qw($Bin);
use lib "$Bin/lib";	#
my @csv_contents = (
    'id,value',
    '1,this',
    '2,that',
    '3,',   # no value
);

#BEGIN {
    my $tmpdir = tempdir( CLEANUP=> 0);
    my $filename = "$tmpdir/file.csv";
    print "$filename\n";
    write_file($filename, map { "$_\n" } @csv_contents);
    config->{log} = "core";
    config->{logger} = "console";
    config->{plugins}{Database}{driver} = "CSV";
    config->{plugins}{Database}{database} = $filename;
#}
require 'TestCRUDFields.pm'; #' ) || die "Can't load test module TestCRUDFields";

## SEE http://www.codeproject.com/Tips/634815/Integrating-Perl-REST-service-with-jQuery-and-a-da
# which describes how to set up Dancer and DBD::CSV / DBI::CSV

route_exists [ GET => '/test_table' ];
response_status_isnt [GET => '/test_table'], 404, "response for GET /test_table is not a 404";

done_testing();

