package FAW::Autogen;

use strict;
use warnings;

use feature ':5.10';
use Moo;

use Try::Tiny;
use Data::Dump qw(dump);
use FindBin qw($Bin);
use POSIX 'strftime';
use YAML qw(LoadFile DumpFile);
use Template;

has 'config_file' => ( is => 'rw', 'required' => 1 );
has 'workaround_path' => ( is => 'rw', 'required' => 1 );

has 'destination_static' => ( is => 'rw' );
has 'destination_view' => ( is => 'rw' );

has 'config' => ( is => 'ro', );
has 'engine' => ( is => 'ro', );

=head2 build_hash

Построить мультиуровневый хэш.

=cut

sub build_hash {
    my $self = shift;
    my $key = shift;
    my $val;
    
    if ( @_ > 0 ) { 
        $val = $self->build_hash(@_);
    } else { 
        $val = {};
    }
    return { $key => $val };
}

=head2 glue_value

Вклеить значение в хэш

=cut

sub glue_value {
    my $self = shift;
    my $config = shift;
    my $val = pop;
    my $key = pop;
    
    if ( @_ > 0 ) {
        my $point = $self->get_hash_link($config, @_);
        ${$point}{$key} = $val;
    } else {
        ${$config}{$key} = $val;
    };
};

=head2 get_hash_link

# получим ссылку на точку в хэше
# последнее значение на входе обязательно должно быть ссылкой на хэш

=cut

sub get_hash_link {
    my $self = shift;
    # получим очередной ключ
    my $hash = shift;
    my $key  = shift;
    
    # если ключ существует
    if ( exists ${$hash}{$key} ) {
        # если значение - хэш и заданы вложенные значения
        if ( ( ref(${$hash}{$key}) =~ /hash/i ) && ( @_ > 0 ) ) {
            return $self->get_hash_link(${$hash}{$key}, @_); 
        }
        # если значение - хэш, но вложенные значения не заданы 
        elsif ( ( ref(${$hash}{$key}) =~ /hash/i ) && ( @_ = 0 ) ) {
            return ${$hash}{$key}
        }
        # если значение - не хэш, и заданы вложенные значения 
        elsif ( ( ref(${$hash}{$key}) !~ /hash/i ) && ( @_ > 0 ) ) {
            #if ( @_ > 1 ) { } else { };
            say " can i build new hash? ";
            $hash->{$key} = $self->build_hash(@_);
        }
        # или значение - не хэш, и вложенные значения не заданы
        else {
            return ${$hash}{$key}
        }
    # если ключа не существует
    } else {
        ${$hash}{$key} = {};
        return ${$hash}{$key};
    };
};


=head2 config_read

Укажите конфигурационный файл, который следует считать в буфер для дальнейшего парсинга.

На выходе получите распарсенный в хэш конфиг.

=cut

sub config_read {
    my ( $self ) = @_;
    my $file = $self->{workaround_path} . '/' . $self->{config_file};
    if ( ! defined($file) ) {
        say " empty config : file absend!";
        return;
    }; 
    
    if ( -e $file ) { 
        $self->{config} = LoadFile($file);
    }
}

=head2 config_write

Процедура записи обновлённой информации в конфигурационный файл

=cut

sub config_write {
    my ( $self ) = @_;
    my $file = $self->{workaround_path} . '/' . $self->{config_file};
    DumpFile($file, $self->{config});
}


=head2 cfg



=cut

sub cfg {
    my ( $self ) = @_;
    return ${$self}{config};
};

=head2 cfg_get

# Прочитать информацию для таблицы-элемента

=cut

sub cfg_get {
    my $self = shift;
    return $self->get_hash_link(${$self}{config}, @_);
}

# Установить информацию для таблицы-элемента
sub cfg_set {
    my $self = shift;
    my $point;
    if ( @_ < 3 ) {
        say " warning! warning! you must use more arguments! ";
        return;
    }
    my $value = pop;
    my $field = pop;
    if ( @_ > 0 ) {
        $point = $self->get_hash_link(${$self}{config}, @_);
    } else {
        $point = ${$self}{config};
    }
    $point->{$field} = $value;
}

# Установить информацию, только если она ранее не была указана
sub cfg_set_if_no_exist {
    my $self    = shift;
    my $val     = pop;
    my $field   = pop;
    
    my $point   = $self->cfg_get(@_);

    if ( ! defined( ${$point}{$field} ) ||
        ref(${$point}{$field}) =~ /^hash$/i ) {
    
        ${$point}{$field} = $val;
    }
}


=head2 path

Описатели путей. Существует ряд точек, которые отличаются от 
базового размещения workaround. Их содержимое хранится в отдельных
ключах настроек и при запросе о них сообщается на выход.
Остальные точки, запрошенные на входе присоединяются к базовому workaround
в виде суффикса и возвращаются целиком.

=cut

sub path {
    my ( $self, $suffix ) = @_;
    $suffix ||= "";
        if ( $suffix =~ /^workaround$/i ) {
        return $self->{workaround_path};
    } elsif ( $suffix =~ /^dst_static$/i ) {
        return $self->{destination_static};
    } elsif ( $suffix =~ /^dst_view$/i ) {
        return $self->{destination_view};
    } else {
        return $self->{workaround_path} . "/$suffix";
    }
}

=head2 prepare_pathes

Процедура верхнего уровня. Для корректной работы следует подготовить
пути, в которых будут храниться производные генерации форм. Для этого
мы вызываем создание папок с перебором всех основных рабочих имён путей. 

=cut

sub prepare_pathes {
    my ( $self ) = @_;
    
    mkdir $self->path();
    mkdir $self->path("elements");
    mkdir $self->path("defaults");
    mkdir $self->path("dst_static");
    mkdir $self->path("dst_view");
}


# Инициирование движка отрисовки форм и элементов 
sub engine_init {
    my ( $self ) = @_;
    my $place_path  = $self->{workaround_path} . "/defaults";
    
    $self->{engine} = Template->new({
        INCLUDE_PATH    => $place_path,
        ENCODING        => "utf8",
    });
}

# Развернуть элементы согласно шаблонам 
sub decode_elements {
    my ( $self, $template_name, $params ) = @_;
    # timestamp, text, varchar, integer, float
    $params    ||= { params => "none" };
    my $place_path  = $self->{workaround_path} . "/defaults/";
    my $result      = "";
    
    if ( ! -e "${place_path}$template_name.tt" ) {
        say " warning: $template_name.tt is absend";
        return "";
    }
    
    try {
        $self->{engine}->process("$template_name.tt", $params, \$result);
    } catch {
        say "can't process $template_name file: is broken";
    };
    return $result;
}

# прочитать из внешнего файла содержимое элемента для встраивания в форму
sub load_element {
    my ( $self, $name ) = @_;
    my $fullname    =  $self->{workaround_path} . "/elements/$name.element";
    my $result_any;
    my $current_block;
    my $ln;
    
    if ( -e $fullname ) {
        open(ELEMENT, $fullname);
        binmode(ELEMENT, ':utf8');
        while ($ln = <ELEMENT>) {
            $ln =~ /^<!-- (\w{2,}) -->$/;
            if ( defined($1) ) {
                $current_block = $1; 
                next; 
            }
            if ( ( ! defined($current_block) ) || ( $current_block =~ /^\s*$/ )) {
                $current_block = "html"; }
            $result_any->{$current_block} .= $ln;
        }
        close(ELEMENT);
    } else {
        say " !!! warning: $fullname is absend";
    }
    
    return $result_any;
}

# вывести в указанный файл указанное значение (переменную)
sub file_out {
    my ( $self, $file, $value ) = @_;
    open(ELEMOUT, ">$file");
    binmode(ELEMOUT, ':utf8');
    print ELEMOUT $value; 
    close(ELEMOUT);
}


=head2 

Комплексная инициализация: чтение конфига, включение движка отрисовки, подготовка (создание) несуществующих путей.

=cut

sub all_init {
    my ( $self ) = @_;

    $self->{config} = {};
    
    $self->config_read();
    $self->engine_init();
    $self->prepare_pathes();
};

1;
