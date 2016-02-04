package FAW::Roles::DDOM; 

#se Moose::Role;
use Moo::Role;

=head1 FAW::Roles::DDOM

    Все элементы HTML могут содержать идентифицирующие поля. Это поля ID и
class. В этой ситуации разумнее всего вынести в отдельную роль эти два поля
(сделав их необязательными) и прописать правила формирования ID поля на
основании неполных данных (при отсутствии явного указания ID).

=cut

=head2 общие поля

    Описательная часть в дереве DOM.

=cut

has 'id'        => (
    is  => 'rw', 
#    isa => 'Str', 
);

has 'classes'   => (
    is  => 'rw', 
#    isa => 'ArrayRef', 
);

=head2 get_id

    Возвращает текущий id поля. Если не указан явно, соберёт из имени поля и
его типа.

=cut

sub get_id {
    my ($self)  = @_;
    return 
        $self->id || $self->type . "_" . $self->name;
}

=head2 get_class

    Класс обязательно хранится в виде ссылки на массив, чтобы иметь возможность
описывать более одного класса одновременно. Таким образом, возвращая класс мы
join'им элементы массива в скаляр.

=cut

sub get_class {
    my ($self)  = @_;
    return "" if !defined($self->classes);
    return join(' ', @{$self->classes});
}


=head2 build_id

    Полученное значение ID элемента мы оборачиваем в html-вид.

=cut

sub build_id {
    my ($self)  = @_;
    my $rez     = sprintf qq(id="%s"), $self->get_id;
    return $rez;
}

=head2 build_class
    
    Полученный список классов мы оборачиваем в html-вид.

=cut

sub build_class {
    my ($self) = @_;
    my $classes = $self->get_class;
    my $rez = ($classes ne "") ? sprintf qq(class="%s"), $classes : "";
    return $rez;
}

1;
