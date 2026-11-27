package TUI::Objects::StrListMaker;
# ABSTRACT: builds a persistent string-list resource

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';
our @EXPORT = qw(
  TStrListMaker
  new_TStrListMaker
);

use Carp ();
use Data::Dumper ();
use FindBin;
use File::Path ();
use File::Spec;
use I18N::LangTags::Detect;
use Storable qw(
  freeze
  thaw
);
use TUI::toolkit;
use TUI::toolkit::Types qw(
  Object
  PositiveOrZeroInt
  Str
  is_Bool
  is_HashRef
  is_Object
  is_PositiveOrZeroInt
  is_Str
);

use TUI::Objects::Object;
use TUI::Objects::Stream;
use TUI::Objects::Streamable;

sub TStrListMaker() { __PACKAGE__ }
sub name() { 'TStringList' }
sub new_TStrListMaker { __PACKAGE__->from(@_) }

extends TObject;
with: *DOES = TStreamable->can('DOES');

use constant HAS_MODULE_RUNTIME => !!eval { require Module::Runtime; 1 };

# declare global variable
our $includePath   = "$FindBin::Bin/local";
our $resourceClass = "MyApp::L10N";
our $languageTag   = I18N::LangTags::Detect::detect() || 'en';

# private attributes
has strSize   => ( is => 'bare' );
has indexSize => ( is => 'bare' );

has tag     => ( is => 'bare', default => sub { $languageTag } );
has lexicon => ( is => 'bare', default => sub { {} } );

sub BUILDARGS {    # \%args ($strSize, $indexSize)
  state $sig = signature(
    method => 1,
    named => [
      strSize   => PositiveOrZeroInt,
      indexSize => PositiveOrZeroInt,
    ],
    caller_level => +1,
  );
  my ( $class, $args ) = $sig->( @_ );
  return { %$args };
}

sub from {    # $obj ($strSize, $indexSize)
  state $sig = signature(
    method => 1,
    pos    => [PositiveOrZeroInt, PositiveOrZeroInt],
  );
  my ( $class, $strSize, $indexSize ) = $sig->( @_ );
  return $class->new( strSize => $strSize, indexSize => $indexSize );
}

sub put {    # void ($key, $string)
  state $sig = signature(
    method => Object,
    pos    => [PositiveOrZeroInt, Str],
  );
  my ( $self, $key, $string ) = $sig->( @_ );
  $self->{lexicon}{$key} = $string
    unless exists $self->{lexicon}{$key};
  return;
}

sub store {    # void ($tag)
  state $sig = signature(
    method => Object,
    pos    => [Str],
  );
  my ( $self, $tag ) = $sig->( @_ );

  # Normalize the language tag to a valid format for the resource class
  my $language = $tag;
  $language =~ tr/-A-Z/_a-z/;
  $language =~ tr/_a-z0-9//cd;

  if ( HAS_MODULE_RUNTIME ) {
    Module::Runtime::is_module_name( $resourceClass )
      or Carp::croak( "Invalid resource class $resourceClass" );
    Module::Runtime::is_module_name( $language )
      or Carp::croak( "Invalid language module $language" );
  }

  # Build the entries string for the lexicon hash
  my $entries = '';
  for my $key ( sort { $a <=> $b } keys %{ $self->{lexicon} } ) {
    my $value = Data::Dumper->new( [ $self->{lexicon}{$key} ] )
      ->Terse(1)
      ->Useqq(1)
      ->Dump;
    chomp $value;
    $entries .= "  $key => $value,\n";
  }

  # Create the source code with the lexicon entries
  my $package = $resourceClass . '::' . $language;
  my $source = <<"SOURCE";
package $package;
use strict;
use warnings;
use utf8;
use parent -norequire, '$resourceClass';
our %Lexicon = (
$entries
);
1;
SOURCE

  # Create the string-list directory if necessary
  my $dir = File::Spec->catdir(
    $includePath, 
    split( /::/, $resourceClass )
  );
  my $errors;
  File::Path::make_path( $dir, { error => \$errors } );
  if ( $errors && @$errors ) {
    Carp::croak( "Could not create string-list resource directory: $dir" );
  }

  # Write the string-list file
  my $path = File::Spec->catfile( $dir, "$language.pm" );
  open my $fh, '>:encoding(UTF-8)', $path
    or Carp::croak("Could not open string-list resource '$path': $!");
  print {$fh} $source
    or Carp::croak("Could not write string-list resource '$path': $!");
  close $fh
    or Carp::croak("Could not close string-list resource '$path': $!");

  $self->{tag} = $language;
  return;
}

sub write :method {    # void ($os)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $os ) = $sig->( @_ );
  assert ( Storable::is_storing );
  $os->put( $self->{tag} );
  return;
}

sub read :method {    # $self ($is)
  state $sig = signature(
    method => Object,
    pos    => [Object],
  );
  my ( $self, $is ) = $sig->( @_ );
  assert ( Storable::is_retrieving );
  ...;
  return undef;
}

sub build {    # $obj ()
  my ( $class ) = @_;
  assert ( @_ == 1 );
  assert ( is_Str $class );
  assert ( Storable::is_retrieving );
  return $class->new(
    strSize   => 0,
    indexSize => 0,
  );
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

TUI::Objects::StrListMaker - collect strings for a keyed string list

=head1 HIERARCHY

  TObject
    TStrListMaker

=head1 SYNOPSIS

  use TUI::Objects;

  my $maker = new_TStrListMaker(128, 16);
  $maker->put(1, 'Hello');
  $maker->store('en');

=head1 DESCRIPTION

C<TStrListMaker> collects strings indexed by nonnegative integer keys for use
in a string list. Use L</put> to add strings. L</store> writes a
L<Locale::Maketext> language resource as a C<.pm> file beneath the configured
C<$includePath>; see L</VARIABLES>.

=head1 VARIABLES

=head2 $includePath

The base directory for string resources. Defaults to the C<local> directory
beneath the running script's directory.

=head2 $languageTag

The initial language tag for a new maker. Defaults to the detected language
tag, or C<en> if none is detected. L</store> still requires an explicit tag.

=head2 $resourceClass

The base class name for string resources. Defaults to C<MyApp::L10N>.

=head1 CONSTRUCTOR

=head2 new

  my $maker = TStrListMaker->new(
    strSize   => $strSize,
    indexSize => $indexSize,
  );

Creates a maker with the specified nonnegative size arguments. The current
implementation does not enforce them as capacity limits.

=head2 new_TStrListMaker

  my $maker = new_TStrListMaker($strSize, $indexSize);

Creates a maker using the positional constructor arguments: string-buffer
size followed by index size.

=head1 METHODS

=head2 put

  $maker->put($key, $string);

Associates C<$string> with the nonnegative integer C<$key>. If the key is
already present, the original string remains unchanged.

=head2 store

  $maker->store($tag);

Writes the generated L<Locale::Maketext> language resource for C<$tag> as a
C<.pm> file beneath C<$includePath>, using C<$resourceClass> as the base
package. A write failure raises an exception.

=head1 SEE ALSO

L<TStringList|TUI::Objects::StringList>,
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
