package TUI::Editors::Const;
# ABSTRACT: constants for editor components

use 5.010;
use strict;
use warnings;

our $VERSION = '2.000002';
$VERSION =~ tr/_//d;
our $AUTHORITY = 'cpan:BRICKPOOL';

use Exporter 'import';

our @EXPORT_OK = qw();

our %EXPORT_TAGS = (

  cpXXXX => [qw(
    cpIndicator
  )],

);

# add all the other %EXPORT_TAGS ":class" tags to the ":all" class and
# @EXPORT_OK, deleting duplicates
{
  my %seen;
  push
    @EXPORT_OK,
      grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}}
        foreach keys %EXPORT_TAGS;
  push
    @{$EXPORT_TAGS{all}},
      @EXPORT_OK;
}

# Palette for TIndicator
use constant {
  cpIndicator => "\x02\x03",
};

1

__END__

=pod

=head1 NAME

TUI::Editors::Const - constants for editor components

=head1 SYNOPSIS

  use TUI::Editors::Const qw( :all );

  # or import specific constant groups
  use TUI::Editors::Const qw( :cpXXXX );

=head1 DESCRIPTION

This module defines constants used by L<TUI::Vision> editor components.

This module only defines constants. The semantic meaning and practical usage of
these constants is documented in the corresponding editor modules.

=head1 CONSTANTS

=head2 Editor color palettes (cpXXXX)

Color palette constants used by editor components.

These values define the color schemes for editor elements, such as the
position indicator L<TIndicator|TUI::Editors::Indicator>.

=head1 EXPORT TAGS

Constants are exported using the following tag-based export groups:

=over

=item * C<:cpXXXX> - editor color palettes

=item * C<:all> - import all constants

=back

=head1 SEE ALSO

L<Editors|TUI::Editors>

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
