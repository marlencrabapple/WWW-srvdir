use Object::Pad ':experimental(:all)';

package WWW::srvdir::config;
role WWW::srvdir::config;

use utf8;
use v5.40;

our $VERSION = "0.01";

use Cwd;
use TOML::Tiny;
use Path::Tiny;
use File::XDG;
use Const::Fast;
use Const::Fast::Exporter;
use Exporter qw(import);

const our $xdg = File::XDG->new( name => __PACKAGE__ );
const our @config_dirs = $xdg->config_dirs_list; # Assuming there's some sort
                                                 # of heirarchal order to this
                                                 # list

our $conig_path;
our $config;

field $config :reader;

APPLY ($mop) {
  foreach my $dir (@config_dirs) {
    $config_path = path("$dir/config.toml");
    if ( -r "$dir/config.toml" ) {
        my ($config, $error) = from_toml $config_path->slurp_utf8;
        
    }
  }
}

ADJUSTPARAMS ($params) {

}

method load_config :common ($path) {

}
