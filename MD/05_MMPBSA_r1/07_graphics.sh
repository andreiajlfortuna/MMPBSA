#!/bin/bash 

rm -rf graphics/

mkdir graphics

cd graphics/


for i in 1 2 4

do

for setup in pb1 pb2 pb3

do

for radii in rstd ropt

do

dir=epsin_${i}/${setup}/${radii}
tail -n +2 ../${dir}/MMPBSA_SUMMARY |awk '{print $1, $4}' > ${setup}_${radii}_epsin_${i}

done
done
done

cp ../dGallframes.plot .

gnuplot dGallframes.plot


cd ../
