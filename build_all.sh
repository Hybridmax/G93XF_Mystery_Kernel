#!/bin/bash

echo "....................................................."
echo "Starting Build for S7-Flat Device"
echo "....................................................."
sleep 5
./build_flat.sh
sleep 3
./repack_flat.sh
sleep 3

clear

echo "....................................................."
echo "Starting Build for S7-Edge Device"
echo "....................................................."
sleep 5
./build_edge.sh
sleep 3
./repack_edge.sh
sleep 3

exit 1
