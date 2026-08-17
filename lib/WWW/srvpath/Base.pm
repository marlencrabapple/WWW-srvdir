use Object::Pad ':experimental(:all)';

package WWW::srvpath::Base;
role WWW::srvpath::Base;

use utf8;
use v5.40;

use PadWalker qw'peek_my var_name';
use IO::Handle::Common 'dmsg';

use parent 'Exporter';

use vars qw'@EXPORT  @EXPORT_OK';

@EXPORT    = qw(dmsg fatal);
@EXPORT_OK = qw(refstr dmsg );

APPLY {
    use v5.40;
    use utf8;
    no warnings 'experimental::re_strict';
    use re 'strict';
}

sub refstr ($ref) {
    reftype($ref) // '';
}

method adjust ( $field, $val ) {
    my $varname = var_name( 0, $field );
    eval "$varname = \$val" if $varname;
    $self;
}

