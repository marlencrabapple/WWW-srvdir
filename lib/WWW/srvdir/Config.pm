use Object::Pad ':experimental(:all)';

package WWW::srvdir::Config;
role WWW::srvdir::Config : does(WWW::srvdir::Base) : does(WWW::srvdir::Util);

use utf8;
use v5.40;

use TOML::Tiny;    #'from_toml';
use Path::Tiny;
use File::HomeDir;
use Const::Fast;
use IO::Handle::Common;
use WWW::srvdir::Util;

const our @CONFIGDIR_DEFAULT =>
  ( File::HomeDir->my_data, path("./")->absolute, );

field $toml = TOML::Tiny->new;
field $file = [
    map  { try_path("$_/srvdir.toml") }
    grep { $_ } @CONFIGDIR_DEFAULT
];
field $data : reader = {};

APPLY {
    # dmsg @CONFIGDIR_DEFAULT, \%$class::, \%ENV,
};

# Default configuration files. May warn on error but will fall back to minimal
# inline config
ADJUST {
    $self->try_config($_) for $file->@*;
};

# User provided/non-default config files. Fatal when path does not exist.
ADJUST : params (:$config = []) {
    $self->load_config($_)
      for @$config;
  }

  method try_config ( $file, %opt ) {
    $self->load_config( $file, %opt, try => 1 );
}

method load_config ( $file, %opt ) {
    my $path = try_path($file);

    if ( !$path->exists ) {
        return undef if $opt{try};
        fatal "Config file '$file' does not exist.";
    }

    my $data_merge = $toml->from_toml( path($path)->slurp_utf8 );
    merge_config($data_merge);
}

method merge_config ( $data_merge, $dest = $data ) {
    foreach my ( $key, $val ) ( $data_merge->%* ) {
        if ( my $val_curr = $$dest{$key} ) {
            if (   ( !ref $val && !ref $val_curr )
                || ( ref $val eq ref $val_curr ) )
            {
                if ( ref $val eq 'ARRAY' ) {
                    push @$val_curr, @$val;
                }
                elsif ( ref $val eq 'HASH' ) {

                    # $val_curr = $self->merge_config( $val, $val_curr );
                    $self->merge_config( $val, $val_curr );
                }
                else {
                    # $$dest{$key} = $val;
                    $val_curr = $val;
                }
            }
            else {
                fatal "Config key '$key' has type mismatch: current type is '"
                  . ref $val_curr
                  . "' but new value has type '"
                  . ref $val . "'";
            }
        }
    }
    $dest;
}

method config (%opt) {
    $data;
}
