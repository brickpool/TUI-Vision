use strict;
use warnings;

use Test::More;

BEGIN {
  use_ok 'TUI::Drivers::ColorDesired';
}

subtest 'construction' => sub {
  my $def = TColorDesired->new();
  isa_ok( $def, TColorDesired, '$def' );

  my $bios = TColorDesired->new( bios => 15 );
  isa_ok( $bios, TColorDesired, '$bios' );

  my $rgb = TColorDesired->new( rgb => 0x7F00BB );
  isa_ok( $rgb, TColorDesired, '$rgb' );

  my $xterm = TColorDesired->new( xterm => 196 );
  isa_ok( $xterm, TColorDesired, '$xterm' );
};

subtest 'type predicates' => sub {
  ok(
    TColorDesired->new()->isDefault,
    'TColorDesired->new()->isDefault'
  );
  ok(
    TColorDesired->new( bios => 0xF )->isBIOS,
    'TColorDesired->new( bios => .. )->isBIOS'
  );
  ok(
    TColorDesired->new( rgb => 0x7F00BB )->isRGB,
    'TColorDesired->new( rgb => .. )->isRGB'
  );
  ok(
    TColorDesired->new( xterm => 196 )->isXTerm,
    'TColorDesired->new( xterm => .. )->isXTerm'
  );
};

subtest 'bitCast' => sub {
  my $c = TColorDesired->new( rgb => 0x7F00BB );
  my $bits = $c->bitCast();
  ok( defined $bits, 'TColorDesired->new( rgb => .. )->bitCast()' );

  my $clone = TColorDesired->new();
  $clone->bitCast( $bits );
  cmp_ok( $clone, '==', $c, 'bits assigned by bitCast is equal to original' );
};

subtest 'equality' => sub {
  my $a = TColorDesired->new( rgb => 0x7F00BB );
  my $b = TColorDesired->new( rgb => 0x7F00BB );
  my $c = TColorDesired->new( rgb => 0x7F00BC );

  cmp_ok( $a, '==', $b, 'a == b' );
  cmp_ok( $a, '!=', $c, 'a != c' );
};

subtest 'toBIOS' => sub {
  ok( 
    defined TColorDesired->new( bios => 15 )->toBIOS( 1 ),
    'TColorDesired->new( bios => .. )->toBIOS( 1 )'
  );
  ok(
    defined TColorDesired->new( rgb => 0x7F00BB )->toBIOS( 1 ),
    'TColorDesired->new( rgb => .. )->toBIOS( 1 )'
  );
  ok(
    defined TColorDesired->new( xterm => 196 )->toBIOS( 1 ),
    'TColorDesired->new( xterm => .. )->toBIOS( 1 )'
  );
};

done_testing;
