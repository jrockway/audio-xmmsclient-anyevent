package Audio::XMMSClient::AnyEvent;
use strict;
use warnings;
use AnyEvent;

use base 'Audio::XMMSClient';

sub _reopen {
    my $id = shift;
    open my $fh, ">&$id" or die "failed to dup $id";
    return $fh;
}

sub _build_watcher {
    my ($self, $name, $direction, $code) = @_;
    if($self->{"has_${name}_watcher"}){
        return $self->{"${name}_watcher"};
    }
    $self->{"${name}_watcher"} = AnyEvent->io(
        fh   => _reopen($self->io_fd_get),
        poll => $direction,
        cb   => sub {
            my $keep_watching = $self->$code;
            if(!$keep_watching){
                $self->_clear_watcher($name);
            }
        },
    );
    $self->{"has_${name}_watcher"} = 1;
    return;
}

sub _clear_watcher {
    my ($self, $name) = @_;
    warn "deleting $name";
    $self->{"has_${name}_watcher"} = 0;
    delete $self->{"${name}_watcher"};
    return;
}

sub connect {
    my $self = shift;
    my $res = $self->SUPER::connect(@_);

    $self->io_need_out_callback_set(\&need_out);
    $self->_build_watcher('in', 'r', 'handle_in');

    return $res;
}

sub need_out {
    my ($self, $flag) = @_;

    if ($self->io_want_out && !$self->{has_out_watcher}) {
        $self->_build_watcher('out', 'w', 'handle_out');
    }
}

sub handle_in {
    my ($self) = @_;
    warn "handling input";
    warn readline($self->io_fd_get);
    $self->io_in_handle;
    return 1;
}

sub handle_out {
    my ($self) = @_;
    warn "io_out_handle";
    $self->io_out_handle;
    return 1; # $self->io_want_out;
}

sub get_loop {
    warn "use the real event loop to do this";
}

sub loop {
    warn "use the real event loop to do this";
}

sub quit_loop {
    warn "use the real event loop to do this";
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
