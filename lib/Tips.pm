# ClamTk, copyright (C) 2004-2016 Dave M
#
# This file is part of ClamTk.
# https://launchpad.net/clamtk
# https://github.com/dave-theunsub/clamtk-gtk3
# https://bitbucket.org/dave_theunsub/clamtk
#
# ClamTk is free software; you can redistribute it and/or modify it
# under the terms of either:
#
# a) the GNU General Public License as published by the Free Software
# Foundation; either version 1, or (at your option) any later version, or
#
# b) the "Artistic License".
package ClamTk::Tips;

use Glib 'TRUE', 'FALSE';

use strict;
use warnings;
$| = 1;

use POSIX 'locale_h';
use Locale::gettext;

my $tips_directory = '';
my $tips_label;
my $last_seen = '';

sub add_box {
    my $box = Gtk3::Box->new( 'vertical', 5 );
    $box->set_border_width( 10 );
  # $box->set_size_request( -1, 500 );
  # $box->override_font( Pango::font_description_from_string( 'Monospace' ) );

    $box->pack_start( add_header(), FALSE, FALSE, 5 );

    my $text_box = Gtk3::Box->new( 'vertical', 5 );
    $box->pack_start( $text_box, TRUE, TRUE, 5 );

    $tips_label = Gtk3::Label->new( '' );
    $text_box->pack_start( $tips_label, TRUE, TRUE, 5 );
    $tips_label->set_line_wrap( TRUE );

    my $viewbar = Gtk3::Toolbar->new;
    $box->pack_start( $viewbar, FALSE, FALSE, 0 );
    # $viewbar->set_style( 'both-horiz' );

    my $sep = Gtk3::SeparatorToolItem->new;
    $sep->set_draw( FALSE );
    $sep->set_expand( TRUE );
    $viewbar->insert( $sep, -1 );

    my $image = Gtk3::Image->new_from_icon_name( 'gtk-next', 3 );
    my $button = Gtk3::ToolButton->new( $image, _( 'Next' ), );
    $button->set_tooltip_text( _( 'Show me another tip' ) );
    $viewbar->insert( $button, -1 );
    $button->set_is_important( TRUE );
    $button->signal_connect( clicked => \&display_text );

    display_text();

    $box->show_all;
    return $box;
}

sub display_text {
    # Don't show the same one twice in a row.
    # This would be perfect for the state variable.
    # Can we assume everyone's using >= 5.010?
    # $last_seen = '';

    my @tips = sort { $a cmp $b } glob "$tips_directory/*.tip";
    my $random;

    while ( 1 ) {
        if ( !@tips ) {
            $tips_label->set_markup( _( 'No tips found.' ) );
            return;
        }
        $random = int( rand( $#tips ) );
        next if ( $last_seen && $last_seen == $random );
        last;
    }

    $last_seen = $random;

    my $slurp = do {
        local $/ = undef;
        open( my $f, ' <:encoding( UTF-8 )', $tips[ $random ] ) or do {
            warn "unable to open >$tips[ $random ]<: $!\n";
            return;
        };
        binmode( $f );
        <$f>;
    };
    $tips_label->set_markup( _( $slurp ) );
    $tips_label->show;
    return;
}

sub add_header {
    my $box = Gtk3::Box->new( 'vertical', 5 );

    my $tips_label = Gtk3::Label->new( '' );
    $tips_label->set_markup( "<b>" . 'Tips' . "</b>" );
    $tips_label->set_alignment( 0.0, 0.5 );
    $box->add( $tips_label );

    $tips_label = Gtk3::Label->new( _( 'Helpful information' ) );
    $tips_label->set_alignment( 0.0, 0.5 );
    $box->add( $tips_label );

    my $sep = Gtk3::Separator->new( 'horizontal' );
    $box->add( $sep );

    return $box;
}

1;
