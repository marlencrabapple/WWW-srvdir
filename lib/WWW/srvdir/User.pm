use Object::Pad ':experimental(:all)';

package WWW::srvdir::User;

role WWW::srvdir::User : does(WWW::srvdir::User::Auth);

use v5.40;
use utf8;

use Const::Fast;
use Data::Dumper;
use Net::SSLeay;
use IO::Handle::Common;

use subs 'hashpass';

field $userdb : reader = [];

# TODO: Maybe use autoload to call in form of (class common technically) method

method add_user ( $name, @pass ) {
    my %user = ( user => $name );

    if ( scalar @pass == 1 ) {
        $user{crypt} =
          WWW::srvdir::User::Auth->is_argon2( $pass[0] )
          ? $pass[0]
          : WWW::srvdir::User::Auth::hashpass( $pass[0] );
    }
    else {
        my %pass = @pass;

        # TODO: eventually support reads from a different key
        my $crypt_key = $user{crypt_key} = $pass{crypt_key} //= 'crypt';

        if ( $pass{password} ) {
            $user{crypt} = WWW::srvdir::User::Auth::hashpass( $pass{password} );
        }
        elsif ( $pass{$crypt_key} ) {
            fatal "Not a valid argon2 hash"
              unless WWW::srvdir::User::Auth->is_argon2( $pass{$crypt_key} );

            $user{crypt} = $pass{$crypt_key};
        }
        else {
            fatal "No cleartext password or argon2 hash given.";
        }
    }

    push @$userdb, \%user;
}
