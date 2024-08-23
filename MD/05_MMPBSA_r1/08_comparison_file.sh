#!/bin/bash 

echo "be careful with n_frames value"

n_frames=1000

echo "this considers ${n_frames}"

rm -rf FINAL_RESULTS_${n_frames}

for i in 1 2 4

do

for setup in pb1 pb2 pb3

do

for radii in rstd ropt

do

G_gas=$(tail -n +2 epsin_${i}/${setup}/${radii}/FINAL_RESULTS | awk -v n_frames=${n_frames} '{sum+=$2;}END{print sum/n_frames;}') 
G_solv=$(tail -n +2 epsin_${i}/${setup}/${radii}/FINAL_RESULTS | awk -v n_frames=${n_frames} '{sum+=$3;}END{print sum/n_frames;}')
G_tot=$(tail -n +2 epsin_${i}/${setup}/${radii}/FINAL_RESULTS | awk -v n_frames=${n_frames} '{sum+=$4;}END{print sum/n_frames;}')
SD=$(awk '{delta = $4 - avg; avg += delta / NR; mean2 += delta * ($4 - avg); } END { print sqrt(mean2 / NR)}' epsin_${i}/${setup}/${radii}/FINAL_RESULTS) 
 
 
echo "epsin_${i}_${setup}_${radii} ${G_tot} ${SD}" >> FINAL_RESULTS_${n_frames}


done 
done 
done
