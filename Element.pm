package FAW::Element; 
use Moose;
use feature ':5.10';

with 'FAW::Roles::DDOM', 'FAW::Roles::Notify';

=head1 FAW::Element

    С точки зрения логики работы, каждая форма состоит из элементов. Этот класс
разворачивает хэш на входе в сопоставленные html-элементы. 

    Каждый элемент обязательно содержит тип и имя. Это непреложный факт.

=cut

has 'type'      => ( is  => 'rw', isa => 'Str', required => 1, );
has 'name'      => ( is  => 'rw', isa => 'Str', required => 1, );

=text

    Помимо этого, элементы описываются дополнительными (необязательными)
полями:
- текущее значение элемента формы;
- значение по умолчанию элемента формы;
- маска ввода значения (в определённом формате, см. jQuery maskedinput;

=cut

has 'value'     => ( is  => 'rw', isa => 'Str', );
has 'default'   => ( is  => 'rw', isa => 'Str', );
has 'mask'      => ( is  => 'rw', isa => 'Str', );

# Контейнет прикрепляемого jQuery-кода
has 'jquery'    => ( is  => 'rw', isa => 'Str', );

=head2 build_element

    На основании хэша на входе строит html-элемент. При сборке учитываются все
связанные значения, в т.ч. класс и идентификатор.
    Сборка возвращает элемент без сопроводительной обёртки в виде метки,
всплывающей подсказки и т.п.

=cut

sub build_element {
    my ($self) = @_;

    my $value = $self->value || $self->default || "";
    my $args = 
        $self->build_id .' '.
        $self->build_class .' '.
        $self->build_tooltip; 

    given ($self->type) {
        when (/input/i) { return sprintf 
                qq(\n\t<input type='text' name='%s' value='%s' %s>),
                $self->name, $value, $args; 
        }
        when (/password/i) { return sprintf
                qq(\n\t<input type='password' name='%s' %s>),
                $self->name, $args; 
        }
        when (/check/i) { return sprintf
                qq(\n\t<input type='checkbox' name='%s' value='%s' %s>),
                $self->name, $value, $args; 
        }
        when (/text/i) { return sprintf
                qq(\n\t<textarea name='%s' %s>%s</textarea>),
                $self->name, $args, $value; 
        }
        when (/button/i) { return sprintf
                qq(\n\t<input type="submit" name="%s" value="%s" %s>),
                $self->name, $self->value, $args;
        }
    };
}

=head2 render_element

    Отрисовывает элемент, заворачивая его в сопроводительную обёртку.

=cut

sub render_element {
    my ($self) = @_;
    my $rez =  
        $self->build_label .' '.
        $self->build_element . ' ' .
        $self->build_note .' '.
        "\n";
    return $rez;
}

=head2 masked_js
    
    Если элементу была сопоставлена маска ввода, то эта процедура вернёт
jQuery-код, подключающий маску к полю ввода.

=cut 

sub build_js_masked {
    my ($self) = @_;
    my $mask = $self->mask || "";

    return ($mask ne "") ? sprintf qq(\$\("#%s"\).mask\("%s"\);), 
        $self->get_id, $self->mask : "";
}

=head2 render_js

    Возвращает завершённый jQuery-код, который можно использовать в парном
скрипте.

=cut 

sub render_js {
    my ($self) = @_;
    my $rez =
        $self->masked_js . ' ' .
        "\n";

    return $rez;
}

__PACKAGE__->meta->make_immutable;

1;
