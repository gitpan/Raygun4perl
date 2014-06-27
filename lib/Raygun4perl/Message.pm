package Raygun4perl::Message;

use Mouse;

use DateTime;
use DateTime::Format::Strptime;
use HTTP::Request;

use Mouse::Util::TypeConstraints;

=head1 NAME

Raygun4perl::Message - A message to be sent to raygun.io

=head1 SYNOPSIS

  use Raygun4perl::Message;


  # The Raygun.io API expects something like this:
  my $data = {
        'occurredOn' => string,
        'details'    => {
            'machineName' => string,
            'version'     => string,
            'client'      => {
                'name'      => string,
                'version'   => string,
                'clientUrl' => string
            },
            'error' => {
                'innerError' => string,
                'data'       => object,
                'className'  => string,
                'message'    => string,
                'stackTrace' => [
                    {
                        'lineNumber' => number,
                        'className'  => string,
                        'fileName'   => string,
                        'methodName' => string,
                    }
                ]
            },
            'environment' => {
                'processorCount'          => number,
                'osVersion'               => string,
                'windowBoundsWidth'       => number,
                'windowBoundsHeight'      => number,
                'resolutionScale'         => string,
                'currentOrientation'      => string,
                'cpu'                     => string,
                'packageVersion'          => string,
                'architecture'            => string,
                'totalPhysicalMemory'     => number,
                'availablePhysicalMemory' => number,
                'totalVirtualMemory'      => number,
                'availableVirtualMemory'  => number,
                'diskSpaceFree'           => array,
                'deviceName'              => string,
                'locale'                  => string,
            },
            'tags'           => array,
            'userCustomData' => object,
            'request'        => {
                'hostName'    => string,
                'url'         => string,
                'httpMethod'  => string,
                'iPAddress'   => string,
                'queryString' => object,
                'form'        => object,
                'headers'     => object,
                'rawData'     => object,
            },
            'response' => {
                'statusCode' => number
            },
            'user' => {
                'identifier' => string
            },
            'context' => {
                'identifier' => string
            }
        }
    };

=head1 DESCRIPTION

This module assembles a request for raygun.io.

=head1 INTERFACE

=cut

use Raygun4perl::Message::Error;
use Raygun4perl::Message::Request;
use Raygun4perl::Message::Environment;


subtype 'MessageError' => as 'Object' => where {
    $_->isa('Raygun4perl::Message::Error');
};

subtype 'OccurredOnDateTime' => as 'Object' => where {
    $_->isa('DateTime');
};

subtype 'Request' => as 'Object' => where {
    $_->isa('Raygun4perl::Message::Request');
};

subtype 'Environment' => as 'Object' => where {
    $_->isa('Raygun4perl::Message::Environment');
};

coerce 'OccurredOnDateTime' => from 'Str' => via {
    my $parser = DateTime::Format::Strptime->new(
        pattern   => '%FT%T%z',
        time_zone => 'UTC',
        on_error  => sub {
            confess
              'Expect time in the following format: yyyy-mm-ddTHH:MM:SS+HHMM';
        }
    );
    return $parser->parse_datetime($_);
};

coerce 'Request' => from 'Object' => via {
    if ($_->isa('HTTP::Request')) {
        my @header_names = $_->header_field_names;
        my $headers;
        foreach my $header (@header_names) {
            my $value = $_->header($header);
            $headers->{$header} = $value;
        }
        my $query_string = $_->uri->query || '';

        return Raygun4perl::Message::Request->new(
            url          => $_->uri->as_string,
            method       => $_->method,
            raw_data     => $_->as_string,
            headers      => $headers,
            http_method => $_->method,
            query_string => $query_string,
        );
    }
};

coerce 'Environment' => from 'HashRef' => via {
    # hope that all the arguments are correct.
    return Raygun4perl::Message::Environment->new(%{$_});
};

coerce 'MessageError' => from 'HashRef' => via {
    return Raygun4perl::Message::Error->new(%{$_});
};

has occurred_on => (
    is      => 'rw',
    isa     => 'OccurredOnDateTime',
    coerce  => 1,
    default => sub {
        return DateTime->now( time_zone => 'UTC' );
    },
);

has error => (
    is  => 'rw',
    isa => 'MessageError',
    coerce => 1,
);

has user => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return $ENV{'RAYGUN_API_USER'} // '';
    }
);

has request => (
    is     => 'rw',
    isa    => 'Request',
    coerce => 1,
);

has environment => (
    is	    => 'rw',
    isa 	=> 'Environment',
    coerce => 1,
    default => sub {
        return {};
    }
);

has user_custom_data => (
    is	    => 'rw',
    isa 	=> 'HashRef',
    default => sub {
        return {};
    },
);

has tags => (
    is	    => 'rw',
    isa 	=> 'ArrayRef',
    default => sub {
        return [];
    },
);

has client => (
    is	    => 'rw',
    isa 	=> 'HashRef',
    default => sub {
        return {};
    },
);

has version => (
    is	    => 'rw',
    isa 	=> 'Str',
    default => sub {
        return '0.1';
    },
);

has machine_name => (
    is	    => 'rw',
    isa 	=> 'Str',
    default => sub {
        return 'Test';
    },
);

=head2 arm_the_laser

Internal method which converts a Perl hash to JSON .

=cut

sub arm_the_laser {
    my $self      = shift;
    my $formatter = DateTime::Format::Strptime->new(
        pattern   => '%FT%TZ',
        time_zone => 'UTC',
    );
    my $occurred_on = $formatter->format_datetime( $self->occurred_on );
    my $data        = {
        occurredOn => $occurred_on,
        details => {
            userCustomData => $self->user_custom_data,
            machineName => $self->machine_name,
            error => $self->error->arm_the_laser,
            version => $self->version,
            client => $self->client,
            request => $self->request->arm_the_laser,
            environment => $self->environment->arm_the_laser,
            user => {
                identifier => $self->user
            },
            context => {
                identifier => undef
            }
        }
    };
    return $data;
}

=head1 DEPENDENCIES


=head1 SEE ALSO


=cut

1;

__END__
