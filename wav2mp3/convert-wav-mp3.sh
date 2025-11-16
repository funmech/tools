#! /bin/bash
cd ~/Music

declare -i base
# in the terminal, ~/Music, run ./getlatest.sh, then run
# export base=999
echo $base

if [[ -v base ]]; then
  echo "base is set to $base."
else
  echo "base is not set. run getlatest.sh and export it to base"
  exit 1
fi

# need to get the total track number of current disk
cda='/run/user/1000/gvfs/cdda:host=sr0'
for i in {1..19}; do
    ni=$(($i+$base))
    n=$(printf "%04d" $ni)
    echo To convert ${cda}/"Track ${i}.wav" to track${n}.mp3
    ffmpeg -i ${cda}/"Track ${i}.wav" -b:a 96k track${n}.mp3
done

