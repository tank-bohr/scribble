#!/usr/bin/perl

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Wx;
use Scribble;

use strict;
use warnings;

Scribble->createAndShow();
