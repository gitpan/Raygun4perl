package Raygun4perl::Message::Environment;

use Mouse;

=head1 NAME

Raygun4perl::Message::Environment - Represent the I<Environment> data in a raygun request.

=head1 SYNOPSIS

  use Raygun4perl::Message::Environment;
  my $environment = Raygun4perl::Message::Environment->new(
    processor_count       => 2,
    cpu                   => 34,
    architecture          => 'x84',
    total_physical_memory => 3
  );


=head1 DESCRIPTION

The environment data is all optional and may be left blank. This class just
initialises them with empty strings or 1s or 0s depending on the context. The
L<arm_the_laser> method may be called to retreive the structure in a form
that can be converted directly to JSON.


=head1 INTERFACE

=cut

use Filesys::DfPortable;
use Sys::Info;
use Sys::Info::OS;
use POSIX ();

has info => (
    is      => 'ro',
    isa     => 'Sys::Info',
    default => sub {
        return Sys::Info->new;
    },
);

has info_os => (
    is      => 'rw',
    isa     => 'Sys::Info::OS',
    default => sub {
        return Sys::Info::OS->new();
    },
);

has processor_count =>
  ( is => 'rw', isa => 'Int', default => sub { return 1; } );
has os_version => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->info->os->name( long => 1 );
    }
);
has fs => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return dfportable( "/", 1024 );
    },
);

has window_bounds_width =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has window_bounds_height =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has resolution_scale =>
  ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has current_orientation =>
  ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has cpu => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->info->device("CPU")->identify;
    }
);
has package_version =>
  ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has architecture => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return (POSIX::uname)[4];
    }
);
has total_physical_memory => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->fs->{blocks};
    }
);
has available_physical_memory => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->fs->{bfree};
    }
);
has total_virtual_memory =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has available_virtual_memory =>
  ( is => 'rw', isa => 'Int', default => sub { return 0; } );
has disk_space_free =>
  ( is => 'rw', isa => 'ArrayRef', default => sub { return [] }, );
has device_name => ( is => 'rw', isa => 'Str', default => sub { return ''; } );
has locale => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->info_os->locale;
    },
);

=head2 arm_the_laser

Return the data structure that will be sent to raygun.io

=cut

sub arm_the_laser {
    my $self = shift;
    return {
        processorCount          => $self->processor_count,
        osVersion               => $self->os_version,
        windowBoundsWidth       => $self->window_bounds_width,
        windowBoundsHeight      => $self->window_bounds_height,
        resolutionScale         => $self->resolution_scale,
        currentOrientation      => $self->current_orientation,
        cpu                     => $self->cpu,
        packageVersion          => $self->package_version,
        architecture            => $self->architecture,
        totalPhysicalMemory     => $self->total_physical_memory,
        availablePhysicalMemory => $self->available_physical_memory,
        totalVirtualMemory      => $self->total_virtual_memory,
        availableVirtualMemory  => $self->available_virtual_memory,
        diskSpaceFree           => $self->disk_space_free,
        deviceName              => $self->device_name,
        locale                  => $self->locale,
    };

}

=head1 DEPENDENCIES


=head1 SEE ALSO

=cut

1;

__END__
