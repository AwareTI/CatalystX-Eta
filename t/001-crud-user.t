use utf8;
use FindBin qw($Bin);
use lib "$Bin/lib";
use lib "$Bin/../lib";

use Test::More;

use MyApp::Test::Further;

my $model = MyApp->model('DB');
ok($model, 'model loaded');
eval {
    $model->schema->deploy_with_users
};
is($@, '', 'database deployed success');




note('this try to create and user. it not really test each class of CatalystX::Eta, but only works if it CatalystX::Eta is working!');

api_auth_as user_id => 1;

db_transaction {

    rest_post '/users',
      name  => 'criar usuario',
      list  => 1,
      stash => 'user',
      [
        name     => 'Foo Bar',
        email    => 'foo1@email.com',
        password => 'foobarquux1',
        role     => 'user'
      ];



    stash_test 'user.get', sub {
        my ($me) = @_;

        is( $me->{id},    stash 'user.id',  'get has the same id!' );
        is( $me->{email}, 'foo1@email.com', 'email ok!' );
        is( $me->{type}, 'user', 'type is correct !' );
    };

    stash_test 'user.list', sub {
        my ($me) = @_;

        ok( $me = delete $me->{users}, 'users list exists' );

        is( @$me, 2, '2 users' );

        $me = [ sort { $a->{id} <=> $b->{id} } @$me ];

        is( $me->[1]{email}, 'foo1@email.com', 'listing ok' );
    };

    rest_put stash 'user.url',
      name => 'atualizar usuario',
      [
        name     => 'AAAAAAAAA',
        email    => 'foo2@email.com',
        password => 'foobarquux1',
        role     => 'user'
      ];

    rest_reload 'user';

    stash_test 'user.get', sub {
        my ($me) = @_;

        is( $me->{email}, 'foo2@email.com', 'email updated!' );
    };

    rest_delete stash 'user.url';

    rest_reload 'user', code => 404;

    # ao inves de
    # my $list = rest_get '/users';
    # use DDP; p $list;

    # utilizar

    rest_reload_list 'user';

    stash_test 'user.list', sub {
        my ($me) = @_;

        ok( $me = delete $me->{users}, 'users list exists' );

        is( @$me, 1, '1 users' );

        is( $me->[0]{email}, 'superadmin@email.com', 'listing ok' );
    };

};




done_testing;
