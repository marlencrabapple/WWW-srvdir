use Object::Pad ':experimental(:all)';

package WWW::srvpath::Base;
role WWW::srvpath::Base;

use utf8;
use v5.40;

use parent 'Exporter';
use PadWalker qw'peek_my var_name';

use vars qw'@EXPORT  @EXPORT_OK';
@EXPORT = qw(refstr);

APPLY {
    use v5.40;
    use utf8;
}

sub refstr ($ref) {
    reftype($ref) // '';
}

method adjust ( $field, $val ) {
    my $varname = var_name( 0, $field );
    eval "$varname = \$val" if $varname;
    $self;
}

