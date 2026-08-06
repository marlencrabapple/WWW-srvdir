use Object::Pad ':experimental(:all)';

package WWW::srvdir::User;

role WWW::srvdir::User : does(WWW::srvdir::User::Auth);

use v5.40;
use utf8;

use Const::Fast;
# use Crypt::Argon2;
use Net::SSLeay;
use IO::Handle::Common;

use subs 'hashpass';

field $userdb : param : accessor = [];
use Getopt::Long
  qw(GetOptionsFromArray :config no_ignore_case auto_abbrev passthrough bundling long_prefix_pattern=--?);

# TODO: Maybe use autoload to call in form of (class common technically) method

method add_user ( $user, @pass ) {
    my %user = ( user => $user );

    if ( scalar @pass == 1 ) {
        $user{crypt} =
          __PACKAGE__->is_argon2( $pass[0] )
          ? $pass[0]
          : __PACKAGE__->hashpass( $pass[0] );
    }
    else {
        my %pass = @pass;
        $user{crypt_key} = $pass{crypt_key} //= 'crypt';

        if ( $pass{password} ) {
            $user{crypt} = __PACKAGE__->hashpass( $pass{password} );
        }
        elsif ( $pass{ $pass{crypt_key} } ) {
            fatal "Not a valid argon2 hash,"
              unless __PACKAGE__->is_argon2( $pass{ $pass{crypt_key} } );
            $user{crypt} = $pass{ $pass{crypt_key} };
        }
        else {
            fatal "No cleartext password or argon2 hash given.";
        }
    }

    push @$userdb, \%user;
}
