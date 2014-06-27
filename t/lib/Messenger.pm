package Messenger;

use strict;
use warnings;

use parent qw(Test::Class);

use Test::More;
use Test::Deep;    # (); # uncomment to stop prototype errors
use Test::Exception;

use HTTP::Request;
#use Smart::Comments;

sub prep001_messenger_available : Test(startup => 2) {
    my $self = shift;
    use_ok('Raygun4perl::Messenger')
      or $self->FAIL_ALL('Messenger class not available.');
    use_ok('Raygun4perl::Message')
      or $self->FAIL_ALL('Message class not available.');

}

sub t0010_raygun_http_403_response : Test(2) {
    my $self = shift;
    my $messenger = Raygun4perl::Messenger->new( api_key => '' );
    my $result;
    lives_ok {
        $result = $messenger->fire_the_laser( {} );
    }
    'Called Raygun.io';
    cmp_ok( $result->code, '==', 403, 'Expect a "Bad Request" error.' );
}

sub t0020_raygun_http_400_response : Test(2) {
    my $self    = shift;
    my $api_key = $ENV{RAYGUN_API_KEY};
    if ( not defined $api_key ) {
        $self->SKIP_ALL('No API key for Raygun.io. No point in continuing.');
    }
    $self->{api_key} = $api_key;
    my $messenger = Raygun4perl::Messenger->new( api_key => $self->{api_key} );
    my $result;
    lives_ok {
        $result = $messenger->fire_the_laser( {} );
    }
    'Called Raygun.io';

    cmp_ok( $result->code, '==', 400, 'Expect a "Bad Request" error.' );

}

sub t0030_raygun_http_ok : Test(2) {
    my $self    = shift;
    my $api_key = $self->{api_key};
    my $message = Raygun4perl::Message->new(
        user => 'null@null.com',
        client => {
            name      => 'something',
            version   => 2,
            clientUrl => 'www.null.com'
        },
        error       => {
            stack_trace => [ { line_number => 34 } ]
        },
        environment => {
            processor_count       => 2,
            cpu                   => 34,
            architecture          => 'x84',
            total_physical_memory => 3
        },
        request => HTTP::Request->new(
            POST => 'https://www.null.com',
            [ 'Content-Type' => 'text/html', ]
        ),

    );

    my $arm_the_laser = $message->arm_the_laser;
    my $messenger = Raygun4perl::Messenger->new( api_key => $self->{api_key} );
    my $response;
    lives_ok {
        $response = $messenger->fire_the_laser($arm_the_laser);
    }
    'Request worked ok';
    ### response : $response
    cmp_ok( $response->code, '<', 400, 'Expect OK response.' );


}

1;

__END__
