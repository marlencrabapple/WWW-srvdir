use Object::Pad ':experimental(:all)';

package WWW::srvdir::Config;
role WWW::srvdir::Config : does(WWW::srvdir::Base);

use utf8;
use v5.40;

use Cwd 'abs_path';
use TOML::Tiny;    #'from_toml';
use Path::Tiny;
use File::HomeDir;

# use File::XDG;
use Const::Fast;
use IO::Handle::Common;

const our @CONFIGDIR_DEFAULT = ( File::HomeDir->my_dist_config, abs_path );

field $toml = TOML::Tiny->nwq field $configfile =
  [ map { try_path("$_/srvdir.toml") } @CONFIGDIR_DEFAULT ];
field $config;

APPLY {
    dmsg @CONFIGDIR_DEFAULT, \%$class::, \%ENV,
}
