use Object::Pad ':experimental(:all)';

package WWW::srvdir::Path;

class WWW::srvdir::Path : isa(Path::Tiny);

use utf8;
use v5.40;

use List::Util qw'none';

use Path::Tiny qw'';
use IO::Handle::Common;

use Exporter;
use parent 'Exporter';

our @EXPORT_OK = qw'path try_path';
our @EXPORT    = @EXPORT_OK;

our $pathlog = {};

field $lastopen  : reader = WWW::srvdir::Util::epoch;
field $lastread  : reader;
field $lastwrite : reader;
field $pathlog   : param = $__PACKAGE__::pathlog;

# sub AUTOLOAD {
#     our $AUTOLOAD;

#     my $invoke = shift;
#     my $method = ( $AUTOLOAD =~ s/^.*:://r );

#     if ( $invoke->isa('WWW::srvdir::Path') ) {
#         if ( $method =~ /^append|spew/ ) {
#             $invokelastwrite = WWW::srvdir::Util::epoch;
#         }
#         elsif ( $method =~ /^lines|slurp/ ) {
#             $lastread = WWW::srvdir::Util::epoch;
#             z;
#         }
#     }
#     else {
#         die "No class common method '$method' ($AUTOLOAD)";
#     }
# }

ADJUST {
    $$pathlog{ $self->canonpath } //= [];
    push $$pathlog{ $self->canonpath }->@*, $self;
}

sub path ( $in, %opt ) {
    __PACKAGE__->new( $in, %opt );
}

sub try_path( $in, %opt ) {
    my $path;

    try {
        $path = path($in)
    }
    catch ($e) {
        error "$e";
        dmsg $in, \%opt, $e;
    }

    $path;
}
