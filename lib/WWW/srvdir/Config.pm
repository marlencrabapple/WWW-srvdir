use Object::Pad ':experimental(:all)';

package WWW::srvdir::Config;
role WWW::srvdir::Config;

use utf8;
use v5.40;

our $VERSION = "0.01";

use Cwd;
use TOML::Tiny 'from_toml';
use Path::Tiny;
use File::XDG;
use Const::Fast;
use Const::Fast::Exporter;
use IO::Handle::Common;

const our $xdg         => File::XDG->new( name => 'WWW::srvdir' );
const our @config_dirs => $xdg->config_dirs_list;  # Assuming there's some sort
                                                   # of heirarchal order to this
                                                   # list

our $_config = {};
const our $CONFIG => $_config;

field $config : reader;

APPLY($mop) {
    my $class = $mop->name;
    $class->load_all_config;
    $class->import;
}

ADJUSTPARAMS($params) {
    $self->init
}

method init {
    __CLASS__->load_all_config( undef, $config );
}

my method load_config : common ($path) {

    if ( -r $path ) {
        my ( $config, $error ) = from_toml( $path->slurp_utf8 );
        dmsg( $class::CONFIG, $error );
        $_config = { %$CONFIG, $config->%* };
    }
}

method load_all_config :
  common ($dir_aref = [@config_dirs], $dest = $class::CONFIG, %opt) {
    foreach my $dir ( $dir_aref->@* ) {

        my $config_path = path("$dir/config.toml");
        dmsg( $dir, $config_path, $class );
        load_config( $class, $config_path );
    }
}
