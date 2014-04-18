package FAW::uRoles;
#use Moose;
use Moo;
use feature ':5.10';

=head1

    Модуль сопоставления и проверок ролей.

=head2 complete_role
    
    Если роль указана в неполном формате (без явно заданных
прав доступа), то считается, что роль имеет полные права доступа.
Однако такую роль следует дополнять дефолтными правами доступа.

=cut

sub complete_role {
    my ( $self, $role ) = @_;

    if   ( $role =~ /\+/ ) { }
    else                   { $role .= "+crud"; }

    return $role;
}

=head2 split_role

=cut

sub split_role {
    my ( $self, $role ) = @_;
    $role =~ s/\s*//g;
    $role = $self->complete_role($role);
    $role =~ /^(!??)(\w+)\+(\w+)$/;
    return [ $1, $2, $3 ];
}

=head2 compare_roles

=cut

sub compare_roles {
    my ( $user_role, $user_action );
    my ( $def_role, $def_action, $def_inverce );

    ( $user_role, $def_role ) = @_;

    say "$user_role";
}

=head2 translate_action

    Преобразует полное имя действия к внутреннему формату обозначения прав
доступа. Если действие неизвестно (нестандартное), то возвратит пустую строку.

=cut

sub translate_action {
    my ( $self, $action ) = @_;
    
    $action =~ s/^put$/c/i;
    $action =~ s/^get$/r/i;
    $action =~ s/^post$/u/i;
    $action =~ s/^delete$/d/i;
    
    return '';
}

=head2 check_role

    Проверяет роль и действие текущего пользователя согласно переданному на
вход списку правил.
    Возвращает 0 при успехе (если правила разрешают пользователю предпринимать
запрошенное действие) или код ошибки, указывающий на причину запрета.
    1 = роль отсутствует в списке;
    2 = роль инверсная, т.е. действие разрешается, если данная роль не
        назначена пользователю;
    3 = запрошенное действие запрещается для этой роли;
    4 = роль не может быть "any";
    5 = нетипичное действие;

=cut

sub check_role {
    my ( $self, $user_role, $user_action, $roles_list) = @_;
    my ( $def_inverce, $def_role, $def_action );
    my $deny_flag = 1;

    ($def_inverce, $user_role, $def_action) = @{$self->split_role($user_role)};
    return 4 if ($user_role eq "any");

    $user_action = $self->translate_action($user_action);
    return 5 if ($user_action eq "");

    foreach my $current_role (split(/,/, $roles_list)) {
        ( $def_inverce, $def_role, $def_action ) = @{$self->split_role($current_role)};
        #say "$current_role : $def_inverce, $def_role, $def_action";
        if ( ( $def_role eq $user_role ) || ( $def_role eq "any" ) ) {
            if ( $def_inverce eq "!" ) { return 2; }
            if ( $def_action =~ /$user_action/i ) { $deny_flag = 0; } 
                else { $deny_flag = 3 };
            #say "$def_action -in- $user_action";
        }
    }
    return $deny_flag;
}

=head2 decode_status

    Выполняет преобразование кода ошибки в краткое текстовое сообщение для
дальнейшего вывода.

=cut

sub decode_status {
    my ($self, $status) = @_;
    
    my $code = {
        0 => "all ok",
        1 => "role not at list",
        2 => "inverted role",
        3 => "denied action",
        4 => "mistake rolename",
        5 => "untypic action",
    };
    
    $status = $code->{$status} || "unknown status";
    return $status;
}

__PACKAGE__->meta->make_immutable;

1;
