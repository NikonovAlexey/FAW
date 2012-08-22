package FAW::Roles; 
use Moose;
use feature ':5.10';

sub compare_roles {
    my ($user_role, $user_action);
    my ($def_role, $def_action, $def_inverce);

    ( $user_role, $def_role ) = @_;

    if ($user_role !~ /\+/) { $user_role .= "+crud"; };
    $user_role =~ /^\![\w?]\+[\w?]$/;
    $user_role = $1; $user_action = $2;
    say "$user_role";
}

__PACKAGE__->meta->make_immutable;

1;
