#!/bin/bash 

for i in 1 2 4

do

mkdir epsin_${i}

cd epsin_${i}/

for setup in pb1 pb2 pb3

do

mkdir ${setup}/

cd ${setup}/

ln -s /home/afortuna/mm-pbsa-ck2/systems_build/set_B/${setup}_${i}.in pb.in

for radii in rstd ropt

do

mkdir ${radii}/

done

cd ../

done 

cd ../

done
