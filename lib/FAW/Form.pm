package FAW::Form;

use feature ':5.10';

use Moo;
use FAW::Element;

use Try::Tiny;
use Carp;
use Data::Dump qw(dump);

with 'FAW::Roles::DDOM';

=head1 FAW::Form

Конструктор формы данных.

Наследует роль DDOM.

Реализует методы, разворачивающие хэш с настройками в HTML-код формы.

Является надстройкой над модулем, преобразующим хэш в HTML-объекты (элементы)
формы. См. модуль FAW::Element;

Форма описывается следующими полями:

formname = имя формы, обязательное поле;

action = действие формы (адрес, на который методом POST будет отправлены данные
    формы);

fields = список (массив) анонимных хэшей-описателей полей формы;

id, classes = стилистические идентификаторы формы, см. FAW::Roles::DDOM;

Особняком стоят такие немаловажные элементы формы, как кнопки. Перечень кнопок
- это отдельный массив элементов.
 
=cut

has 'formname'  => ( is => 'rw', required => 1, );
has 'action'    => ( is => 'rw', );
has 'fields'    => ( is => 'ro', );

has 'title'     => ( is => 'ro', );

has 'buttons'   => ( is => 'ro', );

=head3 build_id

    Процедура генерации ID определённого поля реализована в роли DDOM. Однако
генерация ID для формы отличается от генерации ID для поля, поэтому правило
следует переопределить - поле id="..." возвращается, только если ID был явно
задан для формы.

=cut

sub build_id {
    return "" if !defined($_[0]->id);  
    return ($_[0]->id ne "") ? sprintf qq(id="%s"), $_[0]->id : "";
}


=head2 render_openform 

    Выводит открывающий форму тег. Если явно указаны ID или класс, то перед
формой вставляется открывающий тег DIV.

=cut

sub render_openform {
    my ( $self )    = @_;
    my $parentdom   = $self->build_id . ' ' . $self->build_class;
    my $parentdiv   = ($parentdom =~ /^\s*$/) ? "" : sprintf qq(<div %s>), $parentdom;
    return sprintf qq(%s<form name="%s" action="%s" method="post" enctype="multipart/form-data">),
        $parentdiv, $self->formname, $self->action;
}

=head2 render_items

    Отрисовывает и возвращает на выход элементы формы. Элементы формы выводятся
с помощью парного класса FAW::Element.

=cut

sub render_items {
    my ($self) = @_;
    my $rez = "";

    $rez .= "<p>" . FAW::Element->new($_)->render_element() . "<p>" foreach (@{$self->fields});
    
    return $rez;
}

sub render_items_as_table {
    my ($self) = @_;
    my $rez = "<table>";

    $rez .= "<tr><td>" . FAW::Element->new($_)->render_element_in_table() .  "</td></tr>" foreach (@{$self->fields});
    $rez .= "</table>";
    
    return $rez;
}

=head2 render_buttons

    С точки зрения логики, кнопки - особный набор элементов, который должен
описываться и выводиться отдельным блоком. Кнопки не имеют описательной части
вокруг каждой из них, но им можно передавать id, class и tooltip.

=cut

sub render_buttons {
    my ( $self ) = @_;

    my $rez = "";

    foreach my $btn (@{$self->buttons}) {
        $btn->{type} = "button";
        $rez .= FAW::Element->new($btn)->render_element();
    }
    
    return $rez;
}


=head2 render_closeform

    Отрисуем закрытие формы. Парный тег DIV отрисовывается автоматически по тем
же правилам, что и при открытии формы (при наличии ID и class в описателе
формы).

=cut

sub render_closeform {
    my ( $self ) = @_;

    my $parentdom   = $self->build_id . ' ' . $self->build_class;
    my $parentdiv   = ($parentdom =~ /^\s*$/) ? "" : "</div>";
    return sprintf qq(</form>%s),
        $parentdiv;
}

=head2 render_js

    Каждый элемент формы может иметь парную функцию JavaScript, которая
предназначается для его обработки. С помощью функции render_js можно вернуть
обработчики полей в виде блока функций jQuery.

=cut

sub render_js {
    my ($self) = @_;
    my $rez = "";

    $rez .= FAW::Element->new($_)->render_js() foreach (@{$self->fields});
    
    return $rez;
}


=head2 render_form 

    В большинстве случаев, формы рендерятся по одному и тому же принципу. Тогда
все действия вокруг формы можно сосредоточить в одной команде: отрисовать
форму.

=cut

sub render_form {
    my ( $self ) = @_;

    return sprintf qq(%s
        %s
        %s
        %s
    <script>
    %s
    </script>), 
        $self->render_openform, 
        $self->render_items,
        $self->render_buttons,
        $self->render_closeform,
        $self->render_js;
}

=head2 render_title

=cut

sub render_title {
    my ( $self ) = @_;
    my $title = $self->title || "";

    return sprintf qq(%s),
        $title
}


=head2 empty_form

=cut

sub empty_form {
    my ( $self ) = @_;

    # для всех полей формы
    foreach my $currfield (@{$self->fields}) {
        # очистить очередное поле (имя поля) 
        $currfield->{value}  = ""; 
    }
}

=head2 map_params

Положить в хэш формы полученные параметры формы.
Теперь значение подставляется, только если оно определено.

=cut

sub map_params {
    my ( $self, %params ) = @_;
    my $z;
    
    # для всех полей формы
    foreach my $currfield (@{$self->fields}) {
        # в очередное поле (имя поля) 
        # подставить другое значение или пустоту
        $z = $currfield->{name};
        if ( defined($params{$z}) && ($params{$z} ne "") ) {
            $currfield->{value}  = $params{$z};
        } else {
            $currfield->{value}  = ""; 
        };
    }
}

=head2 map_values 

=cut

sub map_values {
    my ( $self, $item, $params ) = @_;
    my $z;
    
    foreach my $currfield (@{$self->fields}) {
        $z = $currfield->{name};
        next if $z ne $item;
        $currfield->{values} = $params;
    }
}


=head2 map_params_by_names 

Если имя поля и запись в БД совпадает, то можно пользоваться более простым
сопоставлением. Для этого и предназначена эта процедура, которая выполняет
подстановку значений из текущей записи БД в соответствующее поле формы.

После выполнения всех подстановок в хэш значения формы заполняются параметрами
с помощью map_params

=cut 

sub map_params_by_names {
    my ( $self, $schema, @params ) = @_;
    my %keys;

    foreach my $param (@params) {
        if (ref($schema->$param) ne "") {
            try {
            $keys{$param} = $schema->$param->id;
            } catch {
            $keys{$param} = undef;
            };
        } else {
            try {
            $keys{$param} = $schema->$param;
            } catch {
            $keys{$param} = "";
            };
        };
    };
    $self->map_params(%keys);
}

=head2 fieldset

Одно из типовых действий - подстановка текущего значения в поледержатель для
обработки пути перехода. Этот функционал выполняется здесь.

Допускается использовать несколько сопоставлений для более чем одного
поледержателя

=cut

sub fieldset {
    my ( $self, %keys ) = @_;
    my $v;

    foreach my $k (keys(%keys)) {
        $v = $keys{$k} || "";
        $self->{action} =~ s/$k/$v/;
    };

    return $self->{action};
}


__PACKAGE__->meta->make_immutable;

1;
