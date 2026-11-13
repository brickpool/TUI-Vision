use strict;
use warnings;

use Storable qw( freeze thaw );
use Test::More;

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Objects::Point';
  use_ok 'TUI::Editors::Indicator';
}

subtest 'TIndicator Storable roundtrip' => sub {
  my $indicator = TIndicator->new(
    bounds => TRect->new( ax => 0, ay => 23, bx => 40, by => 24 ),
  );
  $indicator->setValue( TPoint->new( x => 4, y => 2 ), !!1 );

  my $restored = thaw( freeze( $indicator ) );
  isa_ok( $restored, TIndicator );
  is_deeply( $restored->{origin}, { x => 0, y => 23 }, 'preserves origin' );
  is_deeply( $restored->{size},   { x => 40, y => 1 }, 'preserves size' );
  is( $restored->{growMode}, $indicator->{growMode}, 'preserves grow mode' );

  # as in Turbo Vision, cursor location and modified flag are not streamed
  is( $restored->{location}{x}, 0, 'does not stream cursor column' );
  is( $restored->{location}{y}, 0, 'does not stream cursor row' );
  ok( !$restored->{modified}, 'does not stream modified state' );
}; #/ 'TIndicator Storable roundtrip' => sub

done_testing();
