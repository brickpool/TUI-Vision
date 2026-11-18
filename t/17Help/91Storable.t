use strict;
use warnings;

use Test::More;
use Storable qw( freeze thaw );

BEGIN {
  use_ok 'TUI::Help::RefTable';
}

subtest 'TRefTable streams metadata but not reference records' => sub {
  my $table = TRefTable->new( limit => 10, delta => 5 );
  $table->getReference( 'beta' );
  my $reference = $table->getReference( 'alpha' );
  $reference->resolved( 1 );
  $reference->val( 100 );

  my $restored = thaw( freeze( $table ) );
  isa_ok( $restored, TRefTable );
  is( $restored->getCount, 2, 'restores the reference count' );
  is( $restored->limit, 10, 'restores the capacity' );
  is( $restored->delta, 5, 'restores the growth increment' );
  ok( !$restored->duplicates, 'preserves the flag after the empty item data' );
  is_deeply( [ $restored->at( 0 ), $restored->at( 1 ) ], [ undef, undef ],
    'readItem returns undefined entries instead of records' );
};

done_testing();
