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

# хранилище значений для списков/перечней/радиокнопок
has 'values'    => ( is  => 'rw', isa => 'Ref', );
# опции, нужные для некоторых jQuery-элементов форм
has 'jqoptions' => ( is  => 'rw', isa => 'Str', );

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
        when (/^text$/i) { return sprintf 
            qq(\n\t<input type='text' name='%s' value='%s' %s>),
            $self->name, $value, $args; 
        }
        when (/^password$/i) { return sprintf
            qq(\n\t<input type='password' name='%s' %s>),
            $self->name, $args; 
        }
        when (/^date|datetime|time$/i) { return sprintf 
            qq(\n\t<input type='text' name='%s' value='%s' %s>),
            $self->name, $value, $args; 
        }
        when (/^check$/i) { return sprintf
            qq(\n\t<input type='checkbox' name='%s' value='%s' %s>),
            $self->name, $value, $args; 
        }
        when (/^switcher$/i) {
            my ($t, $x, $y, $z, $o);
            # переключатели перечислены в массиве хэшей. Каждый переключатель
            # может иметь дополнительный ключ "default", который делает его
            # выбранным по умолчанию.

            # пройдём массив хэшей
            foreach $z (@{$self->values}) { 
                $o = "";
                # разберём хэш с фиксацией ключа и включением checked для
                # выбранного элемента
                foreach $x (keys(%{$z})) {
                    if ($x =~ /default/i) { $o = " checked" }
                    else { $y = $x };
                }; 
                # соберём очередной элемент радиокнопкового списка 
                $t .= sprintf 
                    qq(\n\t<input type='radio' name='%s' value='%s' %s> %s</input>),
                    $self->name, $y, $args . $o, $z->{$y};
            };
            return $t;
        }
        when (/^wysiwyg$/i) { return sprintf
            qq(\n\t<div name='%s' %s>%s</div>),
            $self->name, $args, $value; 
        }
        when (/^upload$/i) { 
            if ($value ne "") { return sprintf 
                qq(\n\t<span %s>%s</span>),
                $args, $value;
            } else { return sprintf 
                qq(\n\t<input type="file" name='%s' %s>),
                $self->name, $args;
            }
        }
        when (/^button$/i) { return sprintf
            qq(\n\t<input type="submit" name="%s" value="%s" %s>),
            $self->name, $self->value, $args;
        }
    };
}

=head2 render_element

    Отрисовывает элемент, заворачивая его в сопроводительную обёртку.

=cut

sub render_element {
    my ($self)  = @_;
    my $label   = $self->build_label || "";
    my $element = $self->build_element || ""; 
    my $note    = $self->build_note || "";
    return      "$label $element $note\n";
}

sub render_element_in_table {
    my ($self)  = @_;
    my $label   = $self->build_label || "";
    my $element = $self->build_element || ""; 
    my $note    = $self->build_note || "";
    
    
    return      ($self->type =~ /^wysiwyg$/) ? 
        "$label</td></tr><tr><td colspan='3'>$element</td></tr><tr><td colspan='3'>$note\n" :
        "$label</td><td>$element</td><td>$note\n" ;
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

=head2 build_js_dated 

    Если тип содержимого date, то подключаем jQuery-обработчик даты.

=cut

sub build_js_dated {
    my ($self)  = @_;
    my $type    = $self->type || "";
    my $options = $self->jqoptions || "";
    
    given ($self->type) {
        when ( /^time$/i ) {
            return sprintf qq(\$\("#%s"\).timepicker\({%s}\);),
                $self->get_id, $options;
        }
        when ( /^datetime$/i ) {
            return sprintf qq(\$\("#%s"\).datetimepicker\({%s}\);),
                $self->get_id, $options;
        }
        when ( /^date$/i ) {
            return sprintf qq(\$\("#%s"\).datepicker\({%s}\);), 
                $self->get_id, $options;
        }
    };
    
    return "";
}

sub build_js_wysiwyg {
    my ( $self ) = @_;

    return "" if ( $self->type !~ /^wysiwyg$/i);
    return sprintf qq|
        \$("#%s").elrte({
            cssClass: 'el-rte',
            height: 400,
            toolbar: 'complete',
            cssfiles: ['css/elrte-inner.css'],
        });
    |, $self->get_id;
};

=head2 render_js

    Возвращает завершённый jQuery-код, который можно использовать в парном
скрипте.

=cut 

sub render_js {
    my ($self) = @_;
    my $rez =
        $self->build_js_masked . ' ' .
        $self->build_js_dated . ' ' .
        $self->build_js_wysiwyg . ' ' .
        "\n";

    return $rez;
}

__PACKAGE__->meta->make_immutable;

1;
