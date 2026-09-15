#!/bin/bash

sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' get_fasta
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_c
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_dc
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_dbb
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_install_database
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_rf
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_si
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_ttt
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_uc
sed -i 's+#!/usr/bin/perl+#!/usr/bin/env perl+' metaxaQR_x

echo "no
$PREFIX/bin
no
yes" | perl ./install_metaxaQR

