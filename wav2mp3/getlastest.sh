#! /bin/bash
last_number=$(ls ~/Music/track*.mp3 | sort -r | head -n 1 | grep -oP 'track\K(\d+)')

cda='/run/user/1000/gvfs/cdda:host=sr0'
echo "The last track number on the disk"
ls $cda | sort -rV | head -n 1

echo "Do remember to export last track number ${last_number} to base"
echo "export base=$last_number"

echo "Do remember to update for loop {1..xx} of convert-wav-mp3.sh"
