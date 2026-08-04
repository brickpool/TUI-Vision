package TUI::Drivers::CellChar;
# ABSTRACT: character value type for screen cells

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000001';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TCellChar
);

require bytes;
use PerlX::Assert::PP;
use Scalar::Util qw( blessed );
use Terminal::WCWidth qw( wcswidth );

sub TCellChar() { __PACKAGE__ }

sub new {    # $cch (|%args)
  my ( $class, @args ) = @_;
  assert ( $class and !ref $class );

  my $text = "\0";
  if ( @args ) {
    return
      unless @args % 2 == 0;
    my %args = @args;
    return
      unless exists $args{text};
    $text = $args{text};
    assert ( !ref $text and length $text );
  }
  return bless \$text, $class;
}

sub getText {    # $ch ()
  assert ( blessed $_[0] );
  return ${ $_[0] };
}

sub size {    # $bytes ()
  assert ( blessed $_[0] );
  return bytes::length( ${ $_[0] } );
}

sub isWide {    # $bool ()
  assert ( blessed $_[0] );
  my $text = ${ $_[0] };
  return !!0
    if bytes::length( $text ) == 1;
  return wcswidth( ${ $_[0] } ) != 1;
}

sub isWideCharTrail {    # $bool ()
  assert ( blessed $_[0] );
  return ${ $_[0] } eq "\0";
}

1;

__END__

=head1 NAME

TCellChar - character value type for screen cells

=head1 SYNOPSIS

  use TUI::Drivers;

  my $ch = TCellChar->new(
    text => 'A',
  );

  my $text = $ch->getText;

=head1 DESCRIPTION

C<TCellChar> represents the text stored in a screen cell.

The stored value is one of:

=over

=item *

ASCII or extended ASCII text occupying a single screen column.

=item *

Multi-byte text occupying one or more screen columns.

=item *

A special wide-character trail placeholder represented by C<"\0">.

=back

=head1 CONSTRUCTOR

=head2 new

Creates a new character value.

Construct an empty value:

  my $ch = TCellChar->new();

Construct from text:

  my $ch = TCellChar->new(
    text => 'A',
  );

Construct a wide-character trail placeholder:

  my $trail = TCellChar->new(
    text => "\0",
  );

=head1 METHODS

=head2 getText

 my $ch = $self->getText();

Returns the stored text.

=head2 isWide

 my $bool = $self->isWide();

Returns true if the stored text does not occupy exactly one screen column.

=head2 isWideCharTrail

 my $bool = $self->isWideCharTrail();

Returns true if the value represents a wide-character trail placeholder.

=head2 size

 my $bytes = $self->size();

Returns the length of the stored text.

=head1 SEE ALSO

L<TScreenCell|TUI::Drivers::ScreenCell>,
L<TColorAttr|TUI::Drivers::ColorAttr>

=head1 AUTHORS

=over

=item * magiblot <magiblot@hotmail.com> (original cell char design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2019-2026 the L</AUTHORS> listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
