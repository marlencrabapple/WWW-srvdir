use Object::Pad ':experimental(:all)';

package WWW::srvdir::User;

role WWW::srvdir::User;

use v5.40;
use utf8;

use Const::Fast;
use Crypt::Argon2;
use Net::SSLeay;
use IO::Handle::Common;

field $userdb : param : accessor = [];

method hashpass ( $pass, $salt = undef, %opt ) {
    my $rv = Net::SSLeay::RAND_bytes( $salt, $opt{salt_bytes} // 1024 );

    fatal "$rv: Could not generate random bytes for salt."
      unless $rv == 1;

    argon2_pass( $pass, $salt );
}

const our $argon2_re => qr/^\$argon2,\$v=[],\$v=[],\$m=[],t=[],p=[]\$[.+]$/x;

method add_user ( $user, @pass ) {
    my %user = ( user => $user );

    if ( scalar @pass == 1 ) {
        if ( $pass[0] =~ $argon2_re ) {
            $user{crypt} = $pass[0];
        }
        else {
            $user{crypt} = $self->hashpass( $pass[0] );
        }
    }
    else {
        my %pass = @pass;
        $user{crypt_key} = $pass{crypt_key} //= 'crypt';

        if ( $pass{password} ) {
            $user{crypt} = $self->hashpass( $pass{password} );
        }
        elsif ( $pass{ $pass{crypt_key} } ) {
            fatal "Not a valid argon2 encoded string"
              unless $pass{ $pass{crypt_key} } =~ $argon2_re;
            $user{crypt} = $pass{ $pass{crypt_key} };
        }
        else {
            fatal "No cleartext password or argon2 hash given.";
        }
    }

    push @$userdb, \%user;
}

method authenticate ( $user, $pass, %opt ) {
    if ( my $user = $self->user($user) ) {
        return $self->verify( $pass,
            $self->user($user)->{ ( $opt{crypt_key} // 'crypt' ) } );
    }
    undef;
}

method verify ( $pass, $crypt, %opt ) {
    argon2_verify( $pass, $crypt );
}
