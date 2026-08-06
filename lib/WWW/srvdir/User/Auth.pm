use Object::Pad ':experimental(:all)';

package WWW::srvdir::User::Auth;

role WWW::srvdir::User::Auth;

use v5.40;
use utf8;

# use System::Info 'sysinfo_hash';
use Const::Fast;
use Net::SSLeay;
use Crypt::Argon2 qw'argon2_pass';
use IO::Handle::Common;
use Syntax::Keyword::MultiSub;
use Const::Fast;

const our $ARGON2_RE => qr/^\$argon2,\$v=[],\$v=[],\$m=[],t=[],p=[]\$[.+]$/x;

# const our $SYSINFO   => sysinfo_hash;
#const $CPUNO =>
const our %ARGON2_DEFAULT => (
    t_cost   => 3,
    m_factor => '64M',

    # parallel   => $$SYSINFO{cpu_cores},
    parallel => (
        map { chomp $_; $_ }
          (`getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu`)
    )[0],
    tag_size   => 32,
    type       => 'argon2id',
    salt_bytes => 512
);

use subs 'hashpass';

field $t_cost   : param : reader = $ARGON2_DEFAULT{t_cost};
field $m_factor : param : reader = $ARGON2_DEFAULT{m_factor};
field $parallel : param : reader = $ARGON2_DEFAULT{parallel};
field $tag_size : param : reader = $ARGON2_DEFAULT{tag_size};

sub hashpass (@opt) {
    my @argon2opt = ();
    my $invoke;

    if ( blessed $opt[0] && ref $opt[0] eq __PACKAGE__
        || $opt[0] eq __PACKAGE__ )
    {
        $invoke = shift @opt;
        ...;
    }

    my $pass = shift @opt;

    fatal "Given password string appears to be an argon2 hash already"
      if $pass =~ $ARGON2_RE;

    my %opt  = (@opt);
    my $type = ( $opt{type} // $ARGON2_DEFAULT{type} );
    my $salt = $opt{salt};    #base64_encode($opt{salt});

    unless ($salt) {
        my $rv =
          Net::SSLeay::RAND_bytes( $salt,
            $opt{salt_bytes} // $ARGON2_DEFAULT{salt_bytes} );

        fatal "$rv: Could not generate random bytes for salt."
          unless $rv == 1;
    }

    @argon2opt = (
        $type, $pass, $salt,
        map { ( $opt{$_} // $ARGON2_DEFAULT{$_} ) }
          (qw't_cost m_factor parallel tag_size')
    );

    dmsg \@argon2opt;

    argon2_pass(@argon2opt);
}

method authenticate ( $user, $pass, %opt ) {
    if ( my $user = $self->user($user) ) {
        return $self->verify( $pass,
            $self->user($user)->{ ( $opt{crypt_key} // 'crypt' ) } );
    }
    undef;
}

method verify ( $pass, $crypt, %opt ) {
    argon2_verify( $pass, $crypt, );
}

method is_argon2 : common ($str) {
    $str =~ $ARGON2_RE;
}
