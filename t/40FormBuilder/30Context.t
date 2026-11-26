use strict;
use warnings;

use File::Temp qw(tempfile);
use Test::More;
use TUI::FormBuilder::Context;

package Test::FormBuilder::View {
  sub load {
    my ( $class, $object ) = @_;

    return bless {
      source  => $object,
      caption => $object->take( 'Caption', '' ),
    }, $class;
  }
}

package Test::FormBuilder::Group {
  use parent -norequire, 'Test::FormBuilder::View';

  sub load {
    my ( $class, $object ) = @_;

    my $self = $class->SUPER::load( $object );
    $self->{children} = [ map { $_->build } $object->children ];

    return $self;
  }
}

package Test::FormBuilder::Recursive {
  sub load {
    my ( $class, $object ) = @_;
    return $object->build;
  }
}

package Test::FormBuilder::Failing {
  sub load {
    die "Target load failed\n";
  }
}

package main;

my $source = <<'FRM';
Version 1.00
BEGIN Form frmAbout
    Caption = "About"
    BackColor = QBColor(1)
    BEGIN CommandButton cmdOK
        Caption = "&OK"
        Tag = "unused"
    END
END
FRM

my @classes = (
  {
    source_type  => 'Form',
    target_class => 'Test::FormBuilder::Group',
  },
  {
    source_type  => 'CommandButton',
    target_class => 'Test::FormBuilder::View',
  },
);

subtest 'load_file builds the root and its children' => sub {
  my ( $fh, $filename ) = tempfile( UNLINK => 1 );
  print {$fh} $source or die "Cannot write $filename: $!";
  close $fh or die "Cannot close $filename: $!";

  my $context = TUI::FormBuilder::Context->new( classes => \@classes );
  my $dialog = $context->load_file( $filename );
  isa_ok( $dialog, 'Test::FormBuilder::Group' );
  is( $dialog->{caption}, 'About', 'root load consumes the caption' );
  is( scalar @{ $dialog->{children} }, 1, 'builds one child' );

  my $button = $dialog->{children}[0];
  isa_ok( $button, 'Test::FormBuilder::View' );
  is( $button->{caption}, '&OK', 'child load consumes its own caption' );
  is( $button->{source}->parent, $dialog->{source},
    'child retains the source parent' );
  is( $button->{source}->context, $context,
    'child uses the same context' );
  is( $dialog->{source}->build, $dialog, 'root is built only once' );
  is( $button->{source}->build, $button, 'child is built only once' );

  is_deeply(
    [ sort map {
      $_->{object}->name . '.' . $_->{property}->name
    } $context->unconsumed_properties ],
    [ 'cmdOK.Tag', 'frmAbout.BackColor' ],
    'reports only unconsumed properties across the tree',
  );
};

subtest 'load_string selects the first matching mapping' => sub {
  my @visited;
  my $context = TUI::FormBuilder::Context->new(
    classes => [
      {
        source_type  => 'Form',
        source_name  => 'anotherForm',
        target_class => 'Test::FormBuilder::Failing',
      },
      {
        source_type  => 'Form',
        target_class => 'Test::FormBuilder::Failing',
        match        => sub { push @visited, 'rejected'; return 0; },
      },
      {
        source_type  => 'Form',
        source_name  => 'frmAbout',
        target_class => 'Test::FormBuilder::Group',
        match        => sub {
          my ( $object ) = @_;
          push @visited, $object->take( 'Caption' );
          return 1;
        },
      },
      {
        source_type  => 'Form',
        target_class => 'Test::FormBuilder::Failing',
      },
      $classes[1],
    ],
  );

  my $first = $context->load_string( $source );
  isa_ok( $first, 'Test::FormBuilder::Group' );
  is_deeply( \@visited, [ 'rejected', 'About' ],
    'checks predicates in registration order after type and name' );
  is( $first->{caption}, 'About',
    'taking a property marks consumption without removing its value' );

  my $second = $context->load_string( $source );
  isnt( $second, $first, 'a new load builds a fresh tree' );
};

subtest 'build errors are explicit and do not poison later loads' => sub {
  my @cases = (
    [ undef, qr/No target class mapped for Form frmAbout/ ],
    [ 'TUI::FormBuilder::Property',
      qr/does not provide load\(\)/ ],
    [ 'Test::FormBuilder::Recursive',
      qr/Recursive build detected for Form frmAbout/ ],
    [ 'Test::FormBuilder::Failing', qr/Target load failed/ ],
  );

  for my $case ( @cases ) {
    my ( $target, $expected ) = @$case;
    my $context = TUI::FormBuilder::Context->new(
      classes => defined $target ? [
        { source_type => 'Form', target_class => $target },
      ] : [],
    );
    my $ok = eval { $context->load_string( $source ); 1 };
    my $error = $@;
    ok( !$ok, 'rejects a build that cannot complete' );
    like( $error, $expected, 'preserves the relevant build error' );
  }

  my $context = TUI::FormBuilder::Context->new;
  my $ok = eval { $context->load_string( $source ); 1 };
  ok( !$ok, 'initial load fails without mappings' );
  $context->register_class( $_ ) for @classes;
  isa_ok( $context->load_string( $source ), 'Test::FormBuilder::Group' );
};

done_testing();
