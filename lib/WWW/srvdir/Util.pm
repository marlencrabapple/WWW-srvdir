use Object::Pad ':experimental(:all)';

package WWW::srvdir::Util;

class WWW::srvdir::Util : does(WWW::srvdir::config);

use utf8;
use v5.40;

use Path::Tiny;
use Const::Fast;
use Syntax::Keyword::Dynamically;
use IO::Handle::Common;
use HTML::Escape;
use URI::Escape;
use Exporter;
use Net::Domain qw'hostfqdn';

use URI;

use parent 'Exporter';

our @EXPORT_OK = qw'path2uri';

# field $cksum = {};
# field $outfile

# field $path = {};

sub path_uri_encode ($pathstr) {

    # my $uri = URI->($str);
    join '/', map { uri_escape_utf8($_) } split qr!/!, $pathstr;
}

sub file_unique( $in, $cksum_href ) {
    $in = path($in);
    my $digest = $in->digest;
    $$cksum_href{$digest} //= [];
    push $$cksum_href{$digest}->@*, $in->absolute;

    my $ret;

    if ( scalar $$cksum_href{$digest}->@* > 1 ) {
        $ret = undef;
        say STDERR "Duplicate file '$in' detected. Other paths: "
          . ( join ', ', $$cksum_href{$digest}->@* ) . "\n";
    }
    else { $ret = 1 }

    $ret;
}

sub path2uri ( $path_aref, %opt ) {

    # my $self = __PACKAGE__->new;
    my %cksum = ();
    my @html;

    $opt{host} //= hostfqdn;

    my $uri = URI->new( $opt{host} );
    $uri->port( $opt{port} ) if $opt{port};

    $uri->scheme('https');

    foreach my ($path) (@$path_aref) {
        dynamically $path = path($path)->absolute;

        next unless $path->is_file;
        next if $opt{unique} && !file_unique( $path, \%cksum );

        my $pathencoded = path_uri_encode($path);
        my $link        = $uri->as_string;

        my $html =
            qq.<a href="$link">.
          . escape_html( path("$path")->basename )
          . "</a><br>";

        dmsg $path, $pathencoded, $link, $html;

        push @html, $html;
    }

    # dmsg \@html;
    join " ", @html;
}

