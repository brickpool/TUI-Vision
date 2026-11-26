package TUI::Gadgets::HeapView::Haiku;
# ABSTRACT: Determine memory usage based on the 'listarea' command

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000003';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use TUI::toolkit qw( :utils );
use TUI::toolkit::Types qw( Object );

sub heapSize {
  state $sig = signature(
    method => Object,
    pos    => [],
  );
  my ( $self ) = $sig->( @_ );
  alias: for my $totalStr ( $self->{heapStr} ) {

  state $next_update = 0;
  state $bytes = -1;

  my $now = time;
  if ( $now < $next_update ) {
    $totalStr = sprintf( "%12d", $bytes )
      if $bytes >= 0;
    return $bytes;
  }
  $next_update = $now + 1;

  $totalStr = "     No heap";

  my $out = qx(listarea $$ 2>/dev/null);
  return -1 unless $out;

  my $mem = 0;
  $mem += $1
    while $out =~ /^\s*
                    \d+      \s+   # area id
                    \S+      \s+   # name
                    0x\S+    \s+   # address
                    \d+      \s+   # locks
                    (\d+)          # bytes
                  /xmg;
  return -1 unless $mem;

  $bytes = $mem;
  $totalStr = sprintf "%12d", $bytes;

  return $bytes;
  }    #/ alias:
}

1;

__END__

=pod

=head1 NAME

TUI::Gadgets::HeapView::Haiku - Haiku heap usage backend for HeapView

=head1 SYNOPSIS

  use TUI::Gadgets::HeapView::Haiku;

  my $total = TUI::Gadgets::HeapView::Haiku->heapSize();

=head1 DESCRIPTION

This module provides the Haiku-specific implementation used by 
L<THeapView|TUI::Gadgets::HeapView> to retrieve memory usage information.

On Haiku, the value is calculated by summing the sizes of all memory
areas reported for the current process by the C<listarea> utility.

The module is not intended to be used directly by application code.

=head1 METHODS

=head2 heapSize

  my $total = TUI::Gadgets::HeapView::Haiku->heapSize();

Returns the amount of memory currently used by the process.

The value is derived from the memory usage reported by the
operating system and is returned in bytes.

To reduce system overhead, the value is cached for up to one second
before being refreshed.

=head1 SEE ALSO

L<THeapView|TUI::Gadgets::HeapView>

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
