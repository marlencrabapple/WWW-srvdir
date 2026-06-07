use Object::Pad ':experimental(:all)';

package WWW::srvdir::Util;

class WWW::srvdir::Util # : does(WWW::srvdir::config);

use utf8;
use v5.40;

use Path::Tiny;
use Const::Fast;
use Syntax::Keyword::Dynamically;
use IO::Handle::Common;
use URI::Escape;

field $cksum = {};
field $outfile :param;
field $path = {};

method file_unique($in) { $in = path($in); my $digest = $in->digest; $$cksum{$digest} //= []; push $$cksum{$digest}->@*, $in->absolute; scalar $$cksum{$digest}->@* ? undef : 1 }

method path2uri (@paths) { my @a_html = (); foreach my ($path) (@paths) {  dynamically $path = path("$path")->absolute; next unless $path->exists && file_unique($path); my $pathencoded = encode_uri_str($path); my $link = "https://cincotuf.lan:1415$pathencoded"; $$path{$path} = $link; my $a = qq.<a href="$link">. . escape_html( path("$path")->basename) . "</a><br>"; push @a_html, $a; dmsg $line; } @a_html }

