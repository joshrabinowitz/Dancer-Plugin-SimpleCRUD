use strict;
use warnings;

use Test::More import => ['!pass'];
use Test::Differences;
use t::lib::TestApp;
use Dancer ':syntax';

use Dancer::Test;
use HTML::TreeBuilder;

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
my $trap = Dancer::Logger::Capture->trap;


main();

sub main {

    # each tests status code, and returns $response and tree of html 
    my ($users_response,                $users_tree)                = crud_fetch_to_htmltree( GET => '/users',                 200 );
    my ($users_editable_response,       $users_editable_tree)       = crud_fetch_to_htmltree( GET => '/users_editable',        200 );
    my ($users_editable_not_addable_response, $users_editable_not_addable_tree)       = crud_fetch_to_htmltree( GET => '/users_editable_not_addable',        200 );
    my ($users_custom_columns_response, $users_custom_columns_tree) = crud_fetch_to_htmltree( GET => '/users_custom_columns',  200 );
    my ($users_customized_column_response, $users_customized_column_tree) = crud_fetch_to_htmltree( GET => '/users_customized_column',  200 );
    my ($users_search_response,         $users_search_tree)         = crud_fetch_to_htmltree( GET => '/users?q=2',             200 );

    ###############################################################################
    # test suggestions from bigpresh:
    # Hmm, I'd like to parse the resulting output, and test:
    #    1) all columns are present as expected
    #    2) supplied custom columns are present
    #    3) values calculated in custom columns are as expected
    #    4) add/edit/delete routes work
    #    5) searching works
    #    6) sorting works
    ###############################################################################

    ###############################################################################
    # high-level test definitions
    ###############################################################################

    # 1) all columns are present as expected
    # this test looks for the 0th thead tag, thenthe 0th tr tag, then compares the text of the tags therein
    test_htmltree_contents( $users_tree,                [qw( thead:0 tr:0 )], ["id", "username", "password",           ], "table headers, not editable" );

    # 1a) check editable table gives 'actions' header
    test_htmltree_contents( $users_editable_tree,       [qw( thead:0 tr:0 )], ["id", "username", "password", "actions" ], "table headers, editable" );

    # 1b) check editable but not addable table also gives 'actions' header
    test_htmltree_contents( $users_editable_not_addable_tree,       [qw( thead:0 tr:0 )], ["id", "username", "password", "actions" ], "table headers, editable" );

    # 2) supplied custom columns are present
    test_htmltree_contents( $users_custom_columns_tree, [qw( thead:0 tr:0 )], ["id", "username", "password", "extra"   ], "table headers, custom column" );

    # 3) values calculated in custom columns are as expected
    test_htmltree_contents( $users_custom_columns_tree, [qw( tbody:0 tr:0 )], ["1", "sukria", "{SSHA}LfvBweDp3ieVPRjAUeWikwpaF6NoiTSK", "Hello, id: 1" ], "table content, custom column" );

    # 3A) overridden customized columns as expected
    test_htmltree_contents( $users_customized_column_tree, [qw( tbody:0 tr:0 )], ["1", "Username: sukria", "{SSHA}LfvBweDp3ieVPRjAUeWikwpaF6NoiTSK", ], "table content, customized column" );

    # 4) add/edit/delete routes work (To Be Written)
    my $response = dancer_response( GET=>"/users_editable/delete/1" );
    cmp_ok( $response->status, "==", 200, "delete route returns 200"  );

    # 5) searching works
    test_htmltree_contents( $users_search_tree,         [qw( tbody:0 tr:0 )], ["2", "bigpresh", "{SSHA}LfvBweDp3ieVPRjAUeWikwpaF6NoiTSK"  ],               "table content, search q=2" );

    # 6) sorting works
    # TODO
    

    my $traps = $trap->read();
    #for my $error (@$traps) {
    #    diag( "trapped $error->{level}: $error->{message}" );
    #}

    # show captured errors
    my @errors = grep { $_->{level} eq "error" } @$traps;
    ok( @errors == 0, "no errors" );
    for my $error (@errors) {
        diag( "trapped $error->{level}: $error->{message}" );
    }

    done_testing();
}

sub crud_fetch_to_htmltree {
    my ($method, $path, $status) = @_;
    my $response = dancer_response( $method=>$path );
    is $response->{status}, $status, "response for $method $path is $status";
    return( $response, HTML::TreeBuilder->new_from_content( $response->{content} ) );
}

sub test_htmltree_contents {
    my ($tree, $elements_spec, $row_contents_expected, $test_name) = @_;
    my $node = $tree;
    for my $e (@$elements_spec) {
        my ($tag, $n) = split(/:/, $e);
        $node = ($node->look_down( '_tag', $tag ))[$n];
        last unless $node;
    }
    return ok(0, "can't find html matching elements_spec (@$elements_spec)") unless $node;

    my @texts = map { $_->as_text() } $node->content_list();
    eq_or_diff( \@texts, $row_contents_expected, $test_name );
}
