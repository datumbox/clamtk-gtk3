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
package ClamTk::InnerAnalysis;

use Glib 'TRUE', 'FALSE';

use strict;
use warnings;
$| = 1;

use POSIX 'locale_h';
use Locale::gettext;

use open ':encoding(utf8)';

sub add_box {
    my $box = Gtk3::Box->new( 'vertical', 5 );
    $box->set_border_width( 10 );
    $box->set_size_request( -1, 500 );
    #$box->override_font(
    #    Pango::font_description_from_string( 'Monospace' )
    #);
    $box->pack_start( add_header(), FALSE, FALSE, 5 );

    my $label_box = Gtk3::Box->new( 'vertical', 0 );
    $box->pack_start( $label_box, TRUE, TRUE, 0 );

    my $label = Gtk3::Label->new(
        _(  'Check the reputation of a file against dozens of security vendors.'
        )
    );
    $label->set_alignment( 0.0, 0.5 );
    $label_box->pack_start( $label, FALSE, FALSE, 5 );

    $label = Gtk3::Label->new(
        _( 'If the file is unknown, you can submit it for analysis.' ) );
    $label->set_alignment( 0.0, 0.5 );
    $label_box->pack_start( $label, FALSE, FALSE, 5 );

    my $infobar = Gtk3::InfoBar->new;
    $infobar->set_message_type( 'warning' );
    $box->pack_start( $infobar, FALSE, FALSE, 0 );

    my $image = Gtk3::Image->new_from_icon_name( 'gtk-dialog-warning', 2 );

    $label = Gtk3::Label->new( '' );
    $label->set_markup(
        _( 'Warning: Do not upload personal or sensitive files' ) );
    $label->set_hexpand( TRUE );
    my $smallbox = Gtk3::Box->new( 'horizontal', 0 );
    $smallbox->pack_start( $image, FALSE, FALSE, 10 );
    $smallbox->pack_start( $label, TRUE,  TRUE,  10 );
    $infobar->get_content_area->add( $smallbox );

    $box->show_all;
    return $box;
}

sub add_header {
    my $box = Gtk3::Box->new( 'vertical', 5 );

    my $label = Gtk3::Label->new( '' );
    $label->set_markup( "<b>" . _( 'Analysis' ) . "</b>" );
    $label->set_alignment( 0.0, 0.5 );
    $box->add( $label );

    $label = Gtk3::Label->new( _( 'Submit a file for analysis' ) );
    $label->set_alignment( 0.0, 0.5 );
    $box->add( $label );

    my $sep = Gtk3::Separator->new( 'horizontal' );
    $box->add( $sep );

    return $box;
}

1;
