#!/usr/bin/env bash

echo "Modifying max_points_per_track in circos housekeeping.conf"
echo "##############################################################################################################################"

sed -i "s/max_points_per_track =.*/max_points_per_track = 70000000/g" $PREFIX/etc/housekeeping.conf