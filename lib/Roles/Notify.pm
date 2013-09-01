package FAW::Roles::Notify; 

#use Moose::Role;
use Moo::Role;

=head1 FAW::Roles::Notify

    Каждый элемент формы может содержать описательные поля. Это:

- метка (label);
- ремарка (note);
- всплывающая подсказк (tooltip);
- сообщение при ошибке (error);

    Все элементы являются необязательными к определению.

=cut

has 'label'     => ( is  => 'rw', );
has 'note'      => ( is  => 'rw', );
has 'error'     => ( is  => 'rw', );
has 'tooltip'   => ( is  => 'rw', );

=head2 build_label

    Метка - это специальное поле, которое выводится возле (как правило, перед)
основным элементом и предназначено для краткой подписи назначения элемента.

=cut

sub build_label {
    my ($self) = @_;
    return "" if !defined($self->label);
    return 
        ($self->label ne "") ? sprintf qq(<label for="%s" class="%s">%s</label>), 
            $self->get_id, $self->get_class, $self->label : "";
}

=head2 build_note

    Ремарка - это особое описание формы, содержащее подробную информацию о
поле, его назначении и ограничениях вводимой информации - всё, что вы
посчитаете нужным сказать пользователю. Сюда же добавляется информация об
ошибке.

=cut

sub build_note {
    my ($self) = @_;
    return "" if !defined($self->note);
    return 
        ($self->note ne "") ? sprintf qq(\n\t<span class="%s">%s %s</span>),
        $self->get_class, $self->note, $self->build_error : "";
}

=head2 build_error

    При возникновении ошибки ввода в определённое поле, возможно, потребуется
прокомментировать ошибку и указать пользователю на то поле, информация в
котором введена некорректно. Для этого предусмотрено определение сообщения об
ошибке.

=cut

sub build_error {
    my ($self) = @_;
    return "" if !defined($self->error);
    return 
        ($self->error ne "") ? sprintf qq(<span class="error">%s</span>), $self->error : "";
}

=head2 build_tooltip

    Всплывающая подсказка может появляться при задерживании мыши над полем
ввода и предоставлять дополнительную (расширенную) информацию для пользователя.

=cut

sub build_tooltip {
    my ($self) = @_;
    return "" if !defined($self->tooltip);
    return 
        ($self->tooltip ne "") ? sprintf qq(tooltip="%s"), $self->tooltip : "";
}

1;
