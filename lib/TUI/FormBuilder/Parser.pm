package TUI::FormBuilder::Parser;

use strict;
use warnings;

use parent 'Parser::MGC';

my @FORM_TYPES = qw(
  Form
  MDIForm
);

# POC set based on the VBDOS control reference and observed FRM input.
my @CONTROL_TYPES = qw(
  CheckBox
  ComboBox
  CommandButton
  DirListBox
  DriveListBox
  FileListBox
  Frame
  HScrollBar
  Image
  Label
  ListBox
  OptionButton
  PictureBox
  TextBox
  Timer
  VScrollBar
);

# POC set based on the VBDOS property reference and observed FRM input.
my @PROPERTY_NAMES = qw(
  Action
  Alignment
  Archive
  Attached
  AutoRedraw
  AutoSize
  BackColor
  BorderStyle
  Cancel
  Caption
  Checked
  ControlBox
  CtlName
  CurrentX
  CurrentY
  Default
  DragMode
  Drive
  Enabled
  FileName
  ForeColor
  FormName
  FormType
  Height
  Hidden
  Index
  Interval
  LargeChange
  Left
  List
  ListCount
  ListIndex
  Max
  MaxButton
  Min
  MinButton
  MousePointer
  MultiLine
  Normal
  Parent
  Path
  Pattern
  ReadOnly
  ScaleHeight
  ScaleWidth
  ScrollBars
  SelLength
  SelStart
  SelText
  Separator
  Shortcut
  SmallChange
  Sorted
  Style
  System
  TabIndex
  TabStop
  Tag
  Text
  Top
  TypeID
  Value
  Visible
  Width
  WindowState
);

sub pattern_comment {
  return qr/'[^\r\n]*/;
}

sub parse {
  my $self = shift;

  my $source_before = $self->substring_before( qr/\bVersion\b/ );

  $self->token_kw( 'Version' );
  my $version = $self->token_number;
  my $form    = $self->form_block;

  my $source_after = $self->substring_before( qr/\z/ );

  return {
    source_before => $source_before,
    version       => $version,
    form          => $form,
    source_after  => $source_after,
  };
}

sub form_block {
  my $self = shift;

  return $self->scope_of(
    'BEGIN',
    sub {
      my $type = $self->form_type;
      my $name = $self->object_name;
      my $body = $self->sequence_of(
        sub {
          $self->commit;
          return $self->any_of(
            'property',
            'object_block',
          );
        }
      );

      return $self->_make_block( $type, $name, $body );
    },
    'END',
  );
} #/ sub form_block

sub form_type {
  my $self = shift;
  return $self->token_kw( @FORM_TYPES );
}

sub object_block {
  my $self = shift;

  $self->expect( qr/(?=BEGIN\b)/ );
  $self->commit;
  return $self->any_of(
    'control_block',
    'custom_block',
    'menu_block',
  );
}

sub control_block {
  my $self = shift;

  return $self->scope_of(
    'BEGIN',
    sub {
      my $type = $self->control_type;
      $self->commit;
      my $name = $self->object_name;
      my $body = $self->sequence_of(
        sub {
          $self->commit;
          return $self->any_of(
            'control_block',
            'custom_block',
            'property',
          );
        }
      );

      return $self->_make_block( $type, $name, $body );
    },
    'END',
  );
}

sub custom_block {
  my $self = shift;

  return $self->scope_of(
    'BEGIN',
    sub {
      my $type = $self->token_kw( 'Custom' );
      $self->commit;
      my $name = $self->object_name;
      my $body = $self->sequence_of(
        sub {
          $self->commit;
          return $self->any_of(
            'control_block',
            'custom_block',
            'custom_property',
          );
        }
      );

      return $self->_make_block( $type, $name, $body );
    },
    'END',
  );
}

sub control_type {
  my $self = shift;
  return $self->token_kw( @CONTROL_TYPES );
}

sub menu_block {
  my $self = shift;

  return $self->scope_of(
    'BEGIN',
    sub {
      $self->token_kw( 'Menu' );
      $self->commit;
      my $name = $self->object_name;
      my $body = $self->sequence_of(
        sub {
          $self->commit;
          return $self->any_of(
            'property',
            'menu_block',
          );
        }
      );

      return $self->_make_block( 'Menu', $name, $body );
    },
    'END',
  );
} #/ sub menu_block

sub object_name {
  my $self = shift;
  return $self->token_ident;
}

sub property {
  my $self = shift;

  my $name = $self->token_kw( @PROPERTY_NAMES );
  $self->commit;
  $self->expect( '=' );
  my $value = $self->value;

  return {
    property => $name,
    value    => $value,
  };
}

sub custom_property {
  my $self = shift;

  my $name = $self->token_ident;
  $self->commit;
  $self->expect( '=' );
  my $value = $self->value;

  return {
    property => $name,
    value    => $value,
  };
}

sub value {
  my $self = shift;

  # Parse compact special values before the general integer and string
  # alternatives. Keeping each special value atomic improves diagnostic
  # locality when nested any_of and sequence_of parsers backtrack.
  return $self->any_of(
    'char_value',
    'color_value',
    'shortcut_value',
    'token_int',
    'string_value',
  );
}

sub char_value {
  my $self = shift;

  return $self->generic_token(
    'char-value' =>  qr/Char\((-?\d+)\)/,
    sub { $_[1] },
  );
}

sub color_value {
  my $self = shift;

  return $self->generic_token(
    'color-value' => qr/QBColor\((-?\d+)\)/,
    sub { $_[1] },
  );
}

sub shortcut_value {
  my $self = shift;

  return $self->generic_token(
    'shortcut-key' => qr/(?:\^\{\w+\}|\^[A-Za-z]|\{\w+\})/,
    sub { $_[1] },
  );
}

sub string_value {
	my $self = shift;

	return $self->generic_token(
		'string' => qr/"((?:""|[^"])*)"/,
		sub {
			my $value = substr( $_[1], 1, -1 );
			$value =~ s/""/"/g;
			return $value;
		},
	);
}

sub _make_block {
  my ( $self, $type, $name, $body ) = @_;

  my %properties;
  my @children;

  for my $item ( @$body ) {
    if ( exists $item->{property} ) {
      $properties{ $item->{property} } = $item->{value};
    }
    else {
      push @children, $item;
    }
  }

  return {
    type       => $type,
    name       => $name,
    properties => \%properties,
    children   => \@children,
  };
} #/ sub _make_block

1;

__END__

=head1 NAME

TUI::FormBuilder::Parser - Parse Visual Basic FRM form definitions

=head1 SYNOPSIS

    my $parser = TUI::FormBuilder::Parser->new;
    my $ast = $parser->from_file('A_CHECK.FRM');

=head1 DESCRIPTION

This proof of concept parses the structured form section of a classic
Visual Basic FRM file and returns a Perl data structure representing the
form, its properties, and its nested controls and menus.

Text before the C<Version> anchor is preserved as C<source_before>. The
C<Version> declaration indicates that a form block follows. Text after the
form block is preserved as C<source_after>.

This module parses FRM syntax only. Conversion of the resulting AST into
Turbo Vision objects or generated source belongs in a separate layer.

=head2 Grammar

    form-block =
        "BEGIN", form-type, object-name,
        { property | object-block },
        "END";

    form-type =
        "Form" | "MDIForm";

    object-block =
        control-block
      | custom-block
      | menu-block;

    control-block =
        "BEGIN", control-type, object-name,
        { control-block | custom-block | property},
        "END";

    custom-block =
        "BEGIN", "Custom", object-name,
        { control-block | custom-block | custom-property },
        "END";

    menu-block =
        "BEGIN", "Menu", object-name,
        { property | menu-block },
        "END";

    property =
        property-name, "=", value;

    custom-property =
        identifier, "=", value;
    
    value =
        char-value
      | color-value
      | shortcut-value
      | integer
      | string;

    char-value =
        "Char", "(", integer, ")";

    color-value =
        "QBColor", "(", integer, ")";

    shortcut-value =
        "{", shortcut-key, "}"
      | "^", "{", shortcut-key, "}"
      | "^", shortcut-letter;

    shortcut-key =
        one or more word characters;

    shortcut-letter =
        one ASCII letter;

=head2 Parser Mapping

C<BEGIN ... END> blocks are parsed with C<scope_of>. Closed keyword sets,
such as form types, control types, and property names, are parsed with
C<token_kw>. Form and Menu blocks and standard control blocks use the
closed property-name set. In a C<Custom> control block, property names use
C<token_ident> instead, so any identifier accepted by that token parser can
be used. Object names also use C<token_ident>.

Both standard and C<Custom> control blocks accept nested control blocks.
The nested blocks are parsed recursively; each block applies its own
property-name rule.

Alternatives use C<any_of>, while repetitions use C<sequence_of>. Integers
and quoted strings use C<token_int> and C<string_value> respectively.

Before parsing each sequence item that is not at the end of its scope, the
parser commits. It also commits after recognizing a property name, and at
the relevant block-choice points: after C<BEGIN>, after a control type, and
after the C<Menu> keyword. These commits prevent enclosing alternatives
from backtracking over a nested failure, preserving the error location
within the malformed item.

The compact forms C<Char(...)>, C<QBColor(...)>, and shortcut values use
C<generic_token>, which enforces their compact lexical forms. Their atomic
parsing alone does not maintain error locality; the commit points above
preserve nested parse error locations when C<any_of> and C<sequence_of>
would otherwise backtrack.

=head2 Comments

An apostrophe starts a comment extending to the end of the line. Comments
are treated as parser whitespace and are not represented in the AST.

=head2 Menu Keys

A menu access key and a shortcut are independent mechanisms. In
C<Caption = "&Save">, the ampersand identifies the access key in the
visible menu level. Shortcut values such as C<{F2}>, C<^{F4}>, and C<^X>
define shortcuts that can invoke the menu item's action without opening
the menu. The parser preserves shortcut values as written, including the
leading C<^> in Control-modified forms.

=head2 Proof-of-Concept Limits

The explicit control type and property name lists include control types and
properties from the VBDOS reference, together with keywords observed in FRM
input. The property list remains closed for Form, Menu, and standard control
blocks; C<Custom> control property names instead accept any identifier. The
explicit control type list may still need entries as additional types are
verified.

Repeated properties currently overwrite earlier values with the same name
inside one block. The proof of concept does not preserve comments or exact
formatting inside the parsed form block.

=cut
