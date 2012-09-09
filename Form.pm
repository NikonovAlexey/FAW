package FAW::Form;
use Moose;
use FAW::Element;
use Data::Dump qw(dump);
use feature ':5.10';

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

has 'formname'  => ( is => 'rw', isa => 'Str', required => 1, );
has 'action'    => ( is => 'rw', isa => 'Str', );
has 'fields'    => ( is => 'ro', isa => 'ArrayRef', );

has 'buttons'   => ( is => 'ro', isa => 'ArrayRef', );

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
    return sprintf qq(<form>%s),
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


=head2 map_params

    Положить в хэш формы полученные параметры формы.

=cut

sub map_params {
    my ( $self, %params ) = @_;
    my $z;
    
    foreach (@{$self->fields}) {
        $z = $_->{name};
        $_->{value}  = $params{$z} || "";
    }
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

__PACKAGE__->meta->make_immutable;

1;
