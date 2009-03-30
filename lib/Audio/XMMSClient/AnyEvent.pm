package Audio::XMMSClient::AnyEvent;
use strict;
use warnings;
use AnyEvent;
use IO::Handle;

use base 'Audio::XMMSClient';

sub connect {
    my $self = shift;
    my $ret = $self->SUPER::connect(@_);

    $self->{fh} = IO::Handle->new_from_fd($self->io_fd_get, 'r+');

    $self->io_need_out_callback_set(\&need_out);
    $self->{in_watch} = AnyEvent->io(
        fh   => $self->{fh},
        poll => 'w',
        cb   => sub { $self->handle_in(@_) },
    );

    return $ret;
}

sub need_out {
    my ($self, $flag) = @_;

    if ($self->io_want_out && !$self->{out_watch}) {
        $self->{out_watch} = AnyEvent->io(
            fh => $self->{fh},
            poll => 'w',
            cb => sub { $self->handle_out(@_) },
        );
    }
}

sub handle_in {
    my ($self) = @_;
    $self->io_in_handle;
    return 1;
}

sub handle_out {
    my ($self) = @_;
    $self->io_out_handle;
    undef $self->{out_watch} unless $self->io_want_out;
}

{
    my $quit = AnyEvent->condvar;

    sub loop {
        $quit->recv;
    }

    sub quit_loop {
        $quit->send;
    }
}

# sub request {
#     my $self = shift;
#     my $func = shift;

#     my $callback  = pop;

#     if (!$self->can($func)) {
#         Carp::croak( "Invalid request name `${func}' given" );
#     }

#     my $cv = AnyEvent->condvar;
#     my $result = $self->$func( @_ );
#     $result->notifier_set(sub { $cv->send( @_ ) });

#     return $cv;
# }

1;
