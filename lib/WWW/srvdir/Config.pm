use Object::Pad ':experimental(:all)';

package WWW::srvdir::Config;
role WWW::srvdir::Config : does(WWW::srvdir::Base);

use utf8;
use v5.40;

use Cwd 'abs_path';
use TOML::Tiny;    #'from_toml';
use Path::Tiny;
use File::HomeDir;
use File::XDG;
use Const::Fast;
use IO::Handle::Common;

use WWW::srvdir::Util;

const our @CONFIGDIR_DEFAULT => ( File::HomeDir->my_dist_config, abs_path );

field $toml = TOML::Tiny->new;
field $configfile =
  [ map { try_path("$_/srvdir.toml") } grep { $_ } @CONFIGDIR_DEFAULT ];
field $config_href : reader = {};

APPLY {
    dmsg @CONFIGDIR_DEFAULT, \%$class::, \%ENV,
};

method config (%opt) {
    $config_href;
}
