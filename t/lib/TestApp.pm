package t::lib::TestApp;

use Dancer;
use Dancer::Plugin::Database;

set session => 'simple';
set plugins => { 'SimpleCRUD' => { provider => 'Config' } };

use Dancer::Plugin::SimpleCRUD;
no warnings 'uninitialized';


hook database_connected => sub {
    my $dbh = shift;
    var(connecthookfired => $dbh);
};

get '/connecthookfired' => sub {
    my $database = database();
    # If the hook fired, it'll have squirreled away a reference to the DB handle
    # for us to look for.
    my $h = var('connecthookfired');
    if (ref $h && $h->isa('DBI::db')) {
        return 1;
    } else {
        return 0;
    }
};

my $last_db_error;
hook 'database_error' => sub {
    $last_db_error = $_[0];
};

get '/errorhookfired' => sub {
    database->do('something silly');
    return $last_db_error ? 1 : 0;
};


get '/prepare_db' => sub {

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
    'ok';
};

get '/' => sub {
    my $sth = database->prepare('select count(*) from users');
    $sth->execute;
    my $total_users = $sth->fetch();
    $total_users->[0] == 7 ? "ok" : "not ok";
};

# Simple example:
if (1) {
    simple_crud(
       record_title => 'Users',
       prefix => '/users',
       db_table => 'user',
       editable => 1,
    );
}
 
1;

__END__

get '/loggedin' => require_login sub  {
    "You are logged in";
};

get '/name' => require_login sub {
    return "Hello, " . logged_in_user->{name};
};

get '/roles' => require_login sub {
    return join ',', sort @{ user_roles() };
};

get '/roles/:user' => require_login sub {
    my $user = param 'user';
    return join ',', sort @{ user_roles($user) };
};

get '/roles/:user/:realm' => require_login sub {
    my $user = param 'user';
    my $realm = param 'realm';
    return join ',', sort @{ user_roles($user, $realm) };
};

get '/realm' => require_login sub {
    return session->{logged_in_user_realm};
};

get '/beer' => require_role BeerDrinker => sub {
    "You can have a beer";
};

get '/piss' => require_role BearGrylls => sub {
    "You can drink piss";
};

get '/piss/regex' => require_role qr/beer/i => sub {
    "You can drink piss now";
};

get '/anyrole' => require_any_role ['Foo','BeerDrinker'] => sub {
    "Matching one of multiple roles works";
};

get '/allroles' => require_all_roles ['BeerDrinker', 'Motorcyclist'] => sub {
    "Matching multiple required roles works";
};

get qr{/regex/(.+)} => require_login sub {
    return "Matched";
};


1;
