use strict;
use warnings;

use Test::More;
use Storable qw( freeze thaw );

BEGIN {
  use_ok 'TUI::Objects::Rect';
  use_ok 'TUI::Outline::OutlineViewer';
}

subtest 'TOutlineViewer Storable roundtrip' => sub {
  my $viewer = TOutlineViewer->new(
    bounds     => TRect->new( ax => 3, ay => 4, bx => 23, by => 14 ),
    hScrollBar => undef,
    vScrollBar => undef,
  );
  $viewer->{foc} = 5;

  my $restored = thaw( freeze( $viewer ) );
  isa_ok( $restored, TOutlineViewer );
  is( $restored->{foc}, 5, 'preserves focused position' );
  is( $viewer->{foc}, 5, 'does not change the original' );
}; #/ 'TOutlineViewer Storable roundtrip' => sub

done_testing();
