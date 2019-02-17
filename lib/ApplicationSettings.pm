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
package ClamTk::ApplicationSettings;

use Glib 'TRUE', 'FALSE';

use strict;
use warnings;

sub add_box {
    my $box = Gtk3::Box->new( 'vertical', 5 );
    $box->set_border_width( 10 );

    my %prefs = ClamTk::Prefs->get_all_prefs();

    $box->pack_start( add_header(), FALSE, FALSE, 5 );

    my $grid = Gtk3::Grid->new;
    $box->pack_start( $grid, TRUE, TRUE, 5 );
    # $grid->set_column_homogeneous( TRUE );
    $grid->set_row_homogeneous( TRUE );
    $grid->set_column_homogeneous( FALSE );
    $grid->set_column_spacing( 30 );
    $grid->set_row_spacing( 5 );

    my $switch = Gtk3::Switch->new;

    # PUA
    my $option = Gtk3::Label->new( _( 'Scan for PUAs' ) );
    $option->set_alignment( 0.0, 0.5 );
    $option->set_tooltip_text(
        _( 'Detect packed binaries, password recovery tools, and more' ) );
    $switch->set_active( TRUE ) if ( $prefs{ Thorough } );
    $grid->attach( $option, 0, 0, 2, 1 );
    $grid->attach( $switch, 2, 0, 2, 1 );
    $switch->signal_connect(
        'notify::active' => sub {
            my ( $btn, $active ) = @_;
            ClamTk::Prefs->set_preference( 'Thorough', $btn->get_active
                ? 1
                : 0 );
        }
    );

    $switch = Gtk3::Switch->new;

    # Hidden files
    $option = Gtk3::Label->new( _( 'Scan files beginning with a dot (.*)' ) );
    $option->set_alignment( 0.0, 0.5 );
    $option->set_tooltip_text( _( 'Scan files typically hidden from view' ) );
    $switch->set_active( TRUE ) if ( $prefs{ ScanHidden } );
    $grid->attach( $option, 0, 1, 2, 1 );
    $grid->attach( $switch, 2, 1, 2, 1 );
    $switch->signal_connect(
        'notify::active' => sub {
            my ( $btn, $active ) = @_;
            ClamTk::Prefs->set_preference( 'ScanHidden', $btn->get_active
                ? 1
                : 0 );
        }
    );

    $switch = Gtk3::Switch->new;

    # Large files
    $option = Gtk3::Label->new( _( 'Scan files larger than 20 MB' ) );
    $option->set_alignment( 0.0, 0.5 );
    $option->set_tooltip_text(
        _( 'Scan large files which are typically not examined' ) );
    $switch->set_active( TRUE ) if ( $prefs{ SizeLimit } );
    $grid->attach( $option, 0, 2, 2, 1 );
    $grid->attach( $switch, 2, 2, 2, 1 );
    $switch->signal_connect(
        'notify::active' => sub {
            my ( $btn, $active ) = @_;
            ClamTk::Prefs->set_preference( 'SizeLimit', $btn->get_active
                ? 1
                : 0 );
        }
    );

    $switch = Gtk3::Switch->new;

    # Recursive
    $option = Gtk3::Label->new( _( 'Scan directories recursively' ) );
    $option->set_alignment( 0.0, 0.5 );
    $option->set_tooltip_text(
        _( 'Scan all files and directories within a directory' ) );
    $switch->set_active( TRUE ) if ( $prefs{ Recursive } );
    $grid->attach( $option, 0, 3, 2, 1 );
    $grid->attach( $switch, 2, 3, 2, 1 );
    $switch->signal_connect(
        'notify::active' => sub {
            my ( $btn, $active ) = @_;
            ClamTk::Prefs->set_preference( 'Recursive', $btn->get_active
                ? 1
                : 0 );
        }
    );

    $switch = Gtk3::Switch->new;

    # Updates
    $option = Gtk3::Label->new( _( 'Check for updates to this program' ) );
    $option->set_alignment( 0.0, 0.5 );
    $option->set_tooltip_text(
        _( 'Check online for application and signature updates' ) );
    $switch->set_active( TRUE ) if ( $prefs{ GUICheck } );
    $grid->attach( $option, 0, 4, 2, 1 );
    $grid->attach( $switch, 2, 4, 2, 1 );
    $switch->signal_connect(
        'notify::active' => sub {
            my ( $btn, $active ) = @_;
            ClamTk::Prefs->set_preference( 'GUICheck', $btn->get_active
                ? 1
                : 0 );
        }
    );

    $switch = Gtk3::Switch->new;

    $option = Gtk3::Label->new( _( 'Double click icons to activate' ) );
    $option->set_alignment( 0.0, 0.5 );
    $option->set_tooltip_text(
        _( 'Uncheck this box to activate icons with single click' ) );
    $switch->set_active( TRUE ) if ( $prefs{ Clickings } == 2 );
    $grid->attach( $option, 0, 5, 2, 1 );
    $grid->attach( $switch, 2, 5, 2, 1 );
    $switch->signal_connect(
        'notify::active' => sub {
            my ( $btn, $active ) = @_;
            ClamTk::Prefs->set_preference( 'Clickings', $btn->get_active
                ? 2
                : 1 );
        }
    );

    $box->show_all;
    return $box;
}

sub add_header {
    my $box = Gtk3::Box->new( 'vertical', 5 );

    my $label = Gtk3::Label->new( '' );
    $label->set_markup( "<b>" . _( 'Application' ) . "</b>" );
    $label->set_alignment( 0.0, 0.5 );
    $box->add( $label );

    $label = Gtk3::Label->new( _( 'View or set application settings' ) );
    $label->set_alignment( 0.0, 0.5 );
    $box->add( $label );

    my $sep = Gtk3::Separator->new( 'horizontal' );
    $box->add( $sep );

    return $box;
}

1;
