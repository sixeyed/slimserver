package Slim::Web::Settings::Player::Remote;

# $Id: Basic.pm 10633 2006-11-09 04:26:27Z kdf $

# SlimServer Copyright (c) 2001-2007 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 2.

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Utils::Strings qw(string);

my $prefs = preferences('server');

sub name {
	return 'REMOTE_SETTINGS';
}

sub page {
	return 'settings/player/remote.html';
}

sub needsClient {
	return 1;
}

sub prefs {
	my ($class, $client) = @_;

	my @prefs = ();

	push @prefs, 'irmap' if (scalar(keys %{Slim::Hardware::IR::mapfiles()}) > 1);

	return ($prefs->client($client), @prefs);
}

sub handler {
	my ($class, $client, $paramRef) = @_;

	if ($client->isPlayer()) {

		# handle disabledirsets here
		if ($paramRef->{'saveSettings'}) {

			my @irsets = keys %{Slim::Hardware::IR::irfiles($client)};
			my @disabled = ();

			for my $i (0 .. (scalar(@irsets)-1)) {

				if ($paramRef->{'irsetlist'.$i}) {

					push @disabled, $paramRef->{'irsetlist'.$i};
				}

				Slim::Hardware::IR::loadIRFile($irsets[$i]);
			}

			$prefs->client($client)->set('disabledirsets', \@disabled);
		}

		$paramRef->{'prefs'}->{'disabledirsets'} = { map {$_ => 1} @{ $prefs->client($client)->get('disabledirsets') } };

		$paramRef->{'irmapOptions'}   = { %{Slim::Hardware::IR::mapfiles()}};
		$paramRef->{'irsetlist'}      = { map {$_ => Slim::Hardware::IR::irfileName($_)} sort(keys %{Slim::Hardware::IR::irfiles($client)})};

	} else {

		# non-SD player, so no applicable display settings
		$paramRef->{'warning'} = string('SETUP_NO_PREFS');
	}

	return $class->SUPER::handler($client, $paramRef);
}

1;

__END__
