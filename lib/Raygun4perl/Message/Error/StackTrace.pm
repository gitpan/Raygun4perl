package Raygun4perl::Message::Error::StackTrace;

use Mouse;

=head1 NAME

Raygun4perl::Message::Error::StackTrace - Encapsule the stacktrace in error details

=head1 SYNOPSIS

  use Raygun4perl::Message::Error::StackTrace;




=head1 DESCRIPTION

# longer description...


=head1 INTERFACE

=cut

has line_number => (
    is      => 'rw',
    isa     => 'Int',
    default => sub {
        return 0;
    },
);

has class_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has file_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

has method_name => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return '';
    },
);

=head2 arm_the_laser

Prepare the data for conversion to JSON.

=cut

sub arm_the_laser {
    my $self = shift;
    return {
        lineNumber => $self->line_number,
        className  => $self->class_name,
        fileName   => $self->file_name,
        methodName => $self->method_name,
    };
}

=head1 DEPENDENCIES


=head1 SEE ALSO


=cut

1;

__END__
