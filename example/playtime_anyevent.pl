#!/usr/bin/perl

use strict;
use warnings;
use Audio::XMMSClient::AnyEvent;

$| = 1;

my $xmms = Audio::XMMSClient::AnyEvent->new('playtime');
$xmms->connect or die;

$xmms->request(signal_playback_playtime => \&pt_callback);

$xmms->loop;

sub pt_callback {
    my ($msec) = @_;

    printf "\r%02d:%02d",
           ($msec / 60000),
           (($msec / 1000) % 60);
}
