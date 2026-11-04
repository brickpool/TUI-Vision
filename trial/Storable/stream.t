use strict;
use warnings;

use Test::More;

use Devel::StrictMode;
use Storable qw( freeze thaw );

BEGIN {
  use_ok 'TUI::Objects::Point';
  use_ok 'TUI::Objects::Rect';
}

BEGIN {
  package TStream;
  use strict;
  use warnings;

  # A stream class constructor for serializing and deserializing data.
  sub new {
    my ( $class ) = @_;
    return bless [], $class;
  }

  # Append values to the stream.
  sub put {
    my ( $self, @values ) = @_;
    push @$self, @values;
    return $self;
  }

  # Read and consume the next value.
  sub get {
    my ( $self ) = @_;
    return shift @$self;
  }

  $INC{'TStream.pm'} = 1;
}

BEGIN {
  package TUI::Objects::Point;
  use strict;
  use warnings;
  use Devel::StrictMode;
  use Storable ();

  sub write {
    my ( $self, $os ) = @_;
    ::note "Writing TUI::Objects::Point: x=$self->{x}, y=$self->{y}";
    $os->put( $self->{x} );
    $os->put( $self->{y} );
    return;
  }

  sub read {
    my ( $self, $is ) = @_;
    $self->{x} = $is->get();
    $self->{y} = $is->get();
    ::note "Reading TUI::Objects::Point: x=$self->{x}, y=$self->{y}";
    return;
  }

  sub STORABLE_freeze {
    my ( $self, $cloning ) = @_;
    return if $cloning;
    my $stream = TStream->new();
    $self->write( $stream );
    return '', $stream;
  }

  sub STORABLE_thaw {
    my ( $self, $cloning, $serialized, $stream ) = @_;
    $self->read( $stream );
    Hash::Util::lock_keys( %$self ) if STRICT;
    return;
  }

}

BEGIN {
  package TPoint3D;
  use strict;
  use warnings;
  use Devel::StrictMode;
  use TUI::Objects::Point;

  use parent TPoint;

  our %HAS; BEGIN {
    %HAS = (
      %TUI::Objects::Point::HAS,
      z => sub { 0 },
    );
  }

  sub new {
    my ( $class, %args ) = @_;
    my $self = $class->SUPER::new( map { $_ => $args{$_} } qw(x y) );
    Hash::Util::unlock_keys( %$self ) if STRICT;
    $self->{z} = $args{z} // $HAS{z}->();
    Hash::Util::lock_keys( %$self ) if STRICT;
    return $self;
  }

  sub write {
    my ( $self, $os ) = @_;
    ::note "Writing TPoint3D: x=$self->{x}, y=$self->{y}, z=$self->{z}";
    $self->SUPER::write( $os );
    $os->put( $self->{z} );
    return
  }

  sub read {
    my ( $self, $is ) = @_;
    $self->SUPER::read( $is );
    $self->{z} = $is->get();
    ::note "Reading TPoint3D: x=$self->{x}, y=$self->{y}, z=$self->{z}";
    return
  }

  $INC{'TPoint3D.pm'} = 1;
}  

BEGIN {
  package TUI::Objects::Rect;
  use strict;
  use warnings;
  use Devel::StrictMode;
  use Storable ();

  sub write {
    my ( $self, $os ) = @_;
    ::note "Writing TUI::Objects::Rect: a=$self->{a}, b=$self->{b}";
    $os->put( $self->{a} );
    $os->put( $self->{b} );
    return;
  }

  sub read {
    my ( $self, $is ) = @_;
    $self->{a} = $is->get();
    $self->{b} = $is->get();
    ::note "Reading TUI::Objects::Rect: a=$self->{a}, b=$self->{b}";
    return;
  }

  sub STORABLE_freeze {
    my ( $self, $cloning ) = @_;
    return if $cloning;
    my $stream = TStream->new();
    $self->write( $stream );
    return '', $stream;
  }

  sub STORABLE_thaw {
    my ( $self, $cloning, $serialized, $stream ) = @_;
    $self->read( $stream );
    Hash::Util::lock_keys( %$self ) if STRICT;
    return;
  }

}

use_ok 'TStream';
use_ok 'TPoint3D';

# Testing TPoint3D serialization and deserialization

my $p = TPoint3D->new(
  x => 10,
  y => 20,
  z => 30,
);
isa_ok( $p, 'TPoint3D' );
is( $p->{z}, 30, 'Checking z coordinate of TPoint3D' );

my ( $serialized, $data ) = $p->STORABLE_freeze( 0 );
is_deeply(
  $data,
  [ 10, 20, 30 ],
  'SUPER payload extended',
);

my $blob = freeze( $p );
my $q    = thaw( $blob );
isa_ok( $q, 'TPoint3D' );

is( $q->{z}, 30, 'Checking z coordinate of thawed TPoint3D' );

# Testing TUI::Objects::Rect serialization and deserialization

my $r = TRect->new(
  ax => 10,
  ay => 20,
  bx => 30,
  by => 40,
);

$blob = freeze( $r );
$q    = thaw( $blob );
isa_ok( $q, TRect );

is( $q->{a}{x}, 10, 'Checking a.x coordinate of thawed TUI::Objects::Rect' );
is( $q->{b}{y}, 40, 'Checking b.y coordinate of thawed TUI::Objects::Rect' );

done_testing();
