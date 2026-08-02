#!/bin/bash

echo "=========================================================================================="
echo "Thank you for installing PSOSP!"
echo ""
echo "To make PSOSP fully functional, you need to download the CheckV database."
echo "Please run the following command and choose a directory for the database:"
echo ""
echo "checkv download_database ./"
echo ""
echo "Then, remember to use the '-db' flag with the path to the database when running psosp."
echo "For example:"
echo "psosp -hf host.fna -vf virus.fna -wd output -db ./checkv-db"
echo "=========================================================================================="

exit 0 