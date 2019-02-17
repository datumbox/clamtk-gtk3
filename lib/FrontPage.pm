# ClamTk, copyright (C) 2004-2016 Dave M
#
# This file is part of ClamTk
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
package ClamTk::FrontPage;

use Glib 'TRUE', 'FALSE';

use strict;
use warnings;
$| = 1;

use Locale::gettext;

sub add_box {
    my $top_box = Gtk3::Box->new( 'vertical', 0 );

    $top_box->pack_start( add_scan_boxes(),   FALSE, FALSE, 10 );
    $top_box->pack_start( add_update_boxes(), FALSE, FALSE, 10 );
    $top_box->pack_start( add_spacer_boxes(), TRUE,  TRUE,  0 );

    return $top_box;
}

sub add_scan_boxes {
    my $overall = Gtk3::Box->new( 'horizontal', 0 );

    my $box = Gtk3::Box->new( 'horizontal', 0 );
    $overall->pack_start( $box, TRUE, TRUE, 0 );

    my $image = Gtk3::Image->new_from_icon_name( 'gtk-file', 6 );
    my $button = Gtk3::Button->new;
    $button->set_image( $image );
    $button->set_relief( 'none' );
    $button->set_always_show_image( TRUE );
    $box->pack_start( $button, FALSE, FALSE, 0 );
    $button->signal_connect( clicked => \&select_file );

    my $header = Gtk3::HeaderBar->new;
    $header->set_title( 'Scan a file' );
    $header->set_subtitle( 'Examine a file for threats' );
    $box->pack_start( $header, TRUE, TRUE, 0 );

    #$box = Gtk3::Box->new( 'horizontal', 0 );
    #$overall->add( $box );

    $image = Gtk3::Image->new_from_icon_name( 'gtk-directory', 6 );
    $button = Gtk3::Button->new;
    $button->set_image( $image );
    $button->set_relief( 'none' );
    $button->set_always_show_image( TRUE );
    $box->pack_start( $button, FALSE, FALSE, 0 );
    $button->signal_connect( clicked => \&select_directory );

    $header = Gtk3::HeaderBar->new;
    $header->override_background_color( 'normal',
        Gtk3::Gdk::RGBA->new( 1, 1, 1, 1 ) );
    $header->set_title( 'Scan a directory' );
    $header->set_subtitle( 'Examine a directory for threats' );
    $box->pack_start( $header, TRUE, TRUE, 0 );

    $overall->show_all;

    return $overall;
}

sub add_update_boxes {
    my $overall = Gtk3::Box->new( 'horizontal', 0 );

    my $box = Gtk3::Box->new( 'horizontal', 0 );
    $overall->pack_start( $box, TRUE, TRUE, 0 );

    my $image = Gtk3::Image->new_from_icon_name( 'gtk-cdrom', 6 );
    my $button = Gtk3::Button->new;
    $button->set_image( $image );
    $button->set_relief( 'none' );
    $button->set_always_show_image( TRUE );
    $button->signal_connect(
            clicked => sub { ClamTk::Device->look_for_device() }
    );
    $box->pack_start( $button, FALSE, FALSE, 0 );

    my $header = Gtk3::HeaderBar->new;
    $header->set_title( gettext( 'Scan a device' ) );
    $header->set_subtitle( 'Examine a device for threats' );
    $box->pack_start( $header, TRUE, TRUE, 0 );

    $image = Gtk3::Image->new_from_icon_name( 'gtk-preferences', 6 );
    $button = Gtk3::Button->new;
    $button->set_image( $image );
    $button->set_relief( 'none' );
    $button->set_always_show_image( TRUE );
    $button->signal_connect( clicked => sub { ClamTk::Settings::show_tab() }
    );
    $box->pack_start( $button, FALSE, FALSE, 0 );

    $header = Gtk3::HeaderBar->new;
    $header->set_title( 'Settings' );
    $header->set_subtitle( 'Set your preferences' );
    $box->pack_start( $header, TRUE, TRUE, 0 );

    $overall->show_all;

    return $overall;
}

sub add_spacer_boxes {
    return Gtk3::Box->new( 'horizontal', 0 );
}

sub select_file {
    my $file   = '';
    my $dialog = Gtk3::FileChooserDialog->new(
        _( 'Select a file' ), undef,
        'open',
        'gtk-cancel' => 'cancel',
        'gtk-ok'     => 'ok',
    );
    $dialog->set_select_multiple( FALSE );
    if ( ClamTk::Prefs->get_preference( 'ScanHidden' ) ) {
        # This does not work.
        $dialog->set_show_hidden( TRUE );
    }
    $dialog->set_position( 'center-on-parent' );
    if ( 'ok' eq $dialog->run ) {
        Gtk3::main_iteration while ( Gtk3::events_pending );
        $file = $dialog->get_filename;
        $dialog->destroy;
    } else {
        $dialog->destroy;
        return FALSE;
    }

    if ( $file =~ m#^(/proc|/sys|/dev)# ) {
        ClamTk::Scan::popup(
            _( 'You do not have permissions to scan that file or directory' )
        );
        undef $file;
        select_file();
    }

    if ( -e $file ) {
        ClamTk::Scan::scan_gui( $file );
    }
}

sub select_directory {
    my $directory = '';
    my $dialog    = Gtk3::FileChooserDialog->new(
        _( 'Select a directory' ), undef,
        'select-folder',
        'gtk-cancel' => 'cancel',
        'gtk-ok'     => 'ok',
    );
    $dialog->set_position( 'center-on-parent' );
    $dialog->set_current_folder( ClamTk::App->get_path( 'directory' ) );
    if ( ClamTk::Prefs->get_preference( 'ScanHidden' ) ) {
        # This does not work.
        $dialog->set_show_hidden( TRUE );
    }
    if ( 'ok' eq $dialog->run ) {
        $directory = $dialog->get_filename;
        Gtk3::main_iteration while ( Gtk3::events_pending );
        $dialog->destroy;
    } else {
        $dialog->destroy;
        return FALSE;
    }

    # May want to enable these one day.  Lots of
    # rootkits hang out under /dev.
    if ( $directory =~ m#^(/proc|/sys|/dev)# ) {
        popup(
            _( 'You do not have permissions to scan that file or directory' )
        );
        undef $directory;
        select_directory();
    }

    if ( -e $directory ) {
        ClamTk::Scan::scan_gui( $directory );
    }
}

sub popup {
    my ( $message, $option ) = @_;

    my $dialog = Gtk3::MessageDialog->new(
        undef,    # no parent
        [ qw| modal destroy-with-parent no-separator | ],
        'info',
        $option ? 'ok-cancel' : 'close',
        $message,
    );

    if ( 'ok' eq $dialog->run ) {
        $dialog->destroy;
        return TRUE;
    }
    $dialog->destroy;

    return FALSE;
}

1;
