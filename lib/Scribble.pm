package Scribble;
our @ISA = qw/Wx::Dialog/;


use strict;
use warnings;
use feature qw/say/;


sub new {
	my $class = shift;
	my @params = @_;

	my $self = $class->SUPER::new( @params );
	my $canvas = 'Wx::Panel'->new($self);
	$canvas->SetBackgroundColour(&Wx::wxWHITE);
	$self->{'canvas'} = $canvas;
	$self->{'last_position'} = 'Wx::Point'->new(0, 0);
	$self->{'button_border'} = 5;
	$self->_createControls();

	return $self
}

sub createAndShow {
	my $class = shift;
	#say $class;

	my $parent = shift;
	my $title = __PACKAGE__;
	my $self = $class->new(
		$parent,
		-1,
		"$title",
		&Wx::wxDefaultPosition,
		&Wx::wxDefaultSize,
		&Wx::wxDEFAULT_DIALOG_STYLE
		# | &Wx::wxCAPTION
	);
	$self->ShowModal();
}

sub getLastPosition {
	my $self = shift;
	return $self->{'last_position'};
}

sub setLastPosition {
	my $self = shift;
	my $value = shift;
	$self->{'last_position'} = $value;
}

sub getCanvas {
	my $self = shift;
	return $self->{'canvas'};
}

sub getButtonBorder {
	my $self = shift;
	return $self->{'button_border'};
}

sub setButtonBorder {
	my $self = shift;
	my $value = shift;
	$self->{'button_border'} = $value;
}

sub _createControls {
	my $self = shift;
	my $canvas = $self->getCanvas();
	
	my $btn_ok = 'Wx::Button'->new($self, &Wx::wxID_OK, 'OK');
	my $btn_clear = 'Wx::Button'->new($self, -1, 'Clear');
	my $btn_save_as = 'Wx::Button'->new($self, -1, 'Save as');
	my $btn_cancel = 'Wx::Button'->new($self, &Wx::wxID_CANCEL, 'Cancel');

	my $top_sizer = 'Wx::BoxSizer'->new(&Wx::wxVERTICAL);
	my $button_sizer = 'Wx::BoxSizer'->new(&Wx::wxHORIZONTAL);
	my $border = $self->getButtonBorder();
	
	Wx::Event::EVT_BUTTON($self, $btn_clear, \&Scribble::onClearButton);
	Wx::Event::EVT_BUTTON($self, $btn_save_as, \&Scribble::onSavAsButton);
	Wx::Event::EVT_LEFT_DOWN($canvas, \&Scribble::onMouseLeft);
	Wx::Event::EVT_MOTION($canvas, \&Scribble::onMouseMoution);
	
	$button_sizer->Add($_, 0, &Wx::wxALL, $border)
		foreach ($btn_ok, $btn_clear, $btn_save_as, $btn_cancel);
	$top_sizer->Add($canvas, 1, &Wx::wxEXPAND | &Wx::wxALL, $border);
	$top_sizer->Add($button_sizer, 0, &Wx::wxALIGN_RIGHT);
	$self->SetSizer($top_sizer);
}

sub getBitmapFilePathFromUser {
	my $self = shift;
	my $file_name = 'scribble';
    my $folder = '';

    my $fd = 'Wx::FileDialog'->new( 
        $self, 'Save file as',
        $folder, $file_name,
        '*.bmp',
        &Wx::wxSAVE | &Wx::wxOVERWRITE_PROMPT
	);
	my ($dir, $path);
    if ($fd->ShowModal() == &Wx::wxID_OK) {
		$dir = $fd->GetDirectory();
		$path = $fd->GetPath();
    };
	return $path;
}

###### Event handlers #####
sub onClearButton {
	my ($wnd, $event) = @_;
	my $dc = 'Wx::ClientDC'->new($wnd->getCanvas());
	$dc->Clear();
}
sub onSavAsButton {
	my ($wnd, $event) = @_;
	my $canvas = $wnd->getCanvas();
	
	my ($width, $height) = $canvas->GetSizeWH();
	my $bmp = 'Wx::Bitmap'->new($width, $height, -1);
	my $dc = 'Wx::ClientDC'->new($canvas);
	my $temp_dc = 'Wx::MemoryDC'->new();
	
	$temp_dc->SelectObject( $bmp );
	$temp_dc->Blit(
		0, 0,              # Destination device context x and y position.
		$width, $height,   # Width and height of source area to be copied
		$dc,               # Source device context
		0, 0               # Source device context x and y position.
	);
	$temp_dc->SelectObject(&Wx::wxNullBitmap);
	
	my $path = $wnd->getBitmapFilePathFromUser();
	#say $path;
	#say &Wx::wxBITMAP_TYPE_PNG;
	$bmp->SaveFile($path, &Wx::wxBITMAP_TYPE_BMP) if $path;
}
sub onMouseLeft {
	my ($panel, $event) = @_;
	my $wnd = $panel->GetParent();
	$wnd->setLastPosition($event->GetPosition());
}
sub onMouseMoution {
	my ($panel, $event) = @_;
	my $wnd = $panel->GetParent();
	if ($event->Dragging()){
		my $position = $event->GetPosition();
		# Device context
		my $dc = 'Wx::ClientDC'->new($panel);
		my $last_position = $wnd->getLastPosition();
		$dc->DrawLine(
			$last_position->x(),
			$last_position->y(),
			$position->x(),
			$position->y()
		);
		$wnd->setLastPosition($position);
	}
}

1;
