#!/usr/bin/perl
use strict;
use warnings;

package App::Addex::AddressBook::Abook;
use base qw(App::Addex::AddressBook);

use App::Addex::Entry::EmailAddress;

use File::HomeDir;
use File::Spec;

{
  package App::Addex::AddressBook::Abook::INI::Reader;
  use Config::INI::Reader; # probably already loaded, but... -- rjbs, 2007-05-09
  BEGIN { our @ISA = 'Config::INI::Reader' }

  sub can_ignore {
    my ($self, $line) = @_;
    return $line =~ /\A\s*(?:[;#]|$)/ ? 1 : 0;
  }

  sub preprocess_line {
    my ($self, $line) = @_;
    ${$line} =~ s/\s+[;#].*$//g;
  }
}

=head1 NAME

App::Addex::AddressBook::Abook - use the "abook" program as the addex source

=head1 VERSION

version 0.006

=cut

our $VERSION = '0.006';

=head1 SYNOPSIS

This module implements the L<App::Addex::AddressBook> interface for the
Mutt-friendly "abook" program.

=head1 CONFIGURATION

The following configuration options are valid:

 filename  - the address book file to read; defaults to ~/.abook/addressbook
 sig_field - the address book entry property that stores the "sig" field
 folder_field - the address book entry property that stores the "sig" field

=cut

sub new {
  my ($class, $arg) = @_;

  my $self = bless {} => $class;
  
  $arg->{filename} ||= File::Spec->catfile(
    File::HomeDir->my_home,
    '.abook',
    'addressbook',
  );

  eval {
    $self->{config} = App::Addex::AddressBook::Abook::INI::Reader
                    ->read_file($arg->{filename});
  };
  Carp::croak "couldn't read abook address book file: $@" if $@;

  $self->{$_} = $arg->{$_} for qw(sig_field folder_field);

  return $self;
}

sub _entrify {
  my ($self, $person) = @_;

  return unless my @emails =
    map { App::Addex::Entry::EmailAddress->new($_) }
    split /\s*,\s*/, ($person->{email}||'');

  my %field;
  $field{ $_ } = $person->{ $self->{"$_\_field"} } for qw(sig folder);

  return App::Addex::Entry->new({
    name   => $person->{name},
    nick   => $person->{nick},
    emails => \@emails,
    fields => \%field,
  });
}

sub entries {
  my ($self) = @_;

  my @entries = map { $self->_entrify($self->{config}{$_}) }
                sort grep { /\A\d+\z/ }
                keys %{ $self->{config} };
}

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2006-2007 Ricardo Signes, all rights reserved.

This program is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
