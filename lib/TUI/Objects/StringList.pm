package TUI::Objects::StringList;
# ABSTRACT: implements a read-only string list

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TStringList
  new_TStringList
);

use Carp             ();
use FindBin          ();
use Locale::Maketext ();
use Module::Load     ();
use Storable qw(
  freeze
  thaw
);
use TUI::toolkit;
use TUI::toolkit::Types qw(
  :is
  :types
);

use TUI::Objects::Object;
use TUI::Objects::Stream;
use TUI::Objects::Streamable;

sub TStringList() { __PACKAGE__ }
sub name() { 'TStringList' }
sub new_TStringList { __PACKAGE__->from(@_) }

extends TObject;
with: *DOES = TStreamable->can('DOES');

# private attributes
has handle => ( is => 'bare' );

sub from {    # $obj ()
  state $sig = signature(
    method => 1,
    pos    => [],
  );
  my ( $class ) = $sig->( @_ );
  return $class->new();
}

sub get {    # $string ($key)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt],
  );
  my ( $self, $key ) = $sig->( @_ );
  return $self->{handle}->maketext("$key");
}

sub load {    # $self ($tag)
  state $sig = signature(
    method => Object,
    pos    => [Str],
  );
  my ( $self, $tag ) = $sig->( @_ );

  # Check if the string-list resource class is valid
  require TUI::Objects::StrListMaker;
  my $resourceClass = $TUI::Objects::StrListMaker::resourceClass;
  if ( TUI::Objects::StrListMaker::HAS_MODULE_RUNTIME() ) {
    Module::Runtime::is_module_name( $resourceClass )
      or Carp::croak( "Invalid resource class $resourceClass" );
  }

  # Set up the environment for loading the string-list
  unless ( $resourceClass->isa( 'Locale::Maketext' ) ) {
    no strict 'refs';
    push @{"${resourceClass}::ISA"}, 'Locale::Maketext';
  }

  # Load the string-list resource for the specified tag
  my $includePath = $TUI::Objects::StrListMaker::includePath;
  local @INC = ( $includePath, @INC );
  my $handle = $resourceClass->get_handle( $tag )
    or Carp::croak( "No string resource '$tag' in $resourceClass" );

  # Empty string for missing keys
  $handle->fail_with( sub { '' } );

  $self->{handle} = $handle;
  return $self;
}

sub write :method {    # void ($os)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $os ) = $sig->( @_ );
  assert ( Storable::is_storing );
  assert ( is_Object $self->{handle} );
  $os->put( $self->{handle}->language_tag() );
  return;
}

sub read :method {    # $self ($is)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $is ) = $sig->( @_ );
  assert ( Storable::is_retrieving );
  $self->load( $is->get() );
  return $self;
}

sub build {    # $obj ()
  my ( $class ) = @_;
  assert ( @_ == 1 );
  assert ( is_Str $class );
  assert ( Storable::is_retrieving );
  return $class->new();
}

sub STORABLE_freeze {    # @list ($cloning)
  my ( $self, $cloning ) = @_;
  assert ( is_Object $self );
  assert ( is_Bool $cloning );
  assert ( not $cloning );

  my $stream = TStream->new();
  $self->write( $stream );
  return freeze $stream;
}

sub STORABLE_attach {    # $obj ($cloning, $serialized)
  my ( $class, $cloning, $serialized ) = @_;
  assert ( is_Str $class );
  assert ( is_Bool $cloning );
  assert ( is_Str $serialized );
  assert ( not $cloning );

  my $self = $class->build();
  my $stream = thaw $serialized;
  return $self->read( $stream );
}

1;

__END__

=pod

=head1 NAME

TUI::Objects::StringList - read-only lookup of strings by numeric key

=head1 HIERARCHY

  TObject
    TStringList

=head1 SYNOPSIS

  use TUI::Objects;

  my $strings = new_TStringList();
  $strings->load('en');
  my $text = $strings->get(1);

=head1 DESCRIPTION

C<TStringList> provides read-only access to strings indexed by nonnegative
integer keys. A lookup for a key that is not present returns the empty
string. Use L</load> to load and select a language resource by tag.

=head1 METHODS

=head2 get

  my $string = $strings->get($key);

Returns the L<Locale::Maketext> result for the nonnegative integer C<$key>, or
the empty string if no string is associated with that key.

For straightforward application use, this Perl method follows the Pascal
Turbo Vision 2.0 form C<Get(Key): String> rather than the C++ output-parameter
form C<get(char *dest, ushort key)>.

=head2 load

  $strings->load($tag);

Loads and selects a language resource for C<$tag>, returning the
C<TStringList> object. The base path and resource class are configured by
C<$includePath> and C<$resourceClass>. An exception is raised if no resource 
handle can be obtained. See also 
L<TStrListMaker configuration|TUI::Objects::StrListMaker/VARIABLES>.

=head1 SEE ALSO

L<TStrListMaker|TUI::Objects::StrListMaker>,
L<TObject|TUI::Objects::Object>

=head1 AUTHORS

=over

=item * Borland International (original Turbo Vision design)

=item * J. Schneider <brickpool@cpan.org> (Perl implementation and maintenance)

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 1990-1994, 1997 by Borland International

Copyright (c) 2026 the L</AUTHORS> as listed above.

This software is licensed under the MIT license (see the LICENSE file, which is
part of the distribution).

=cut
