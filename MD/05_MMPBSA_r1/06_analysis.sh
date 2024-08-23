#!/bin/bash 

n_frames=1000
init_frame=1
tot_frames=1000



for i in 1 2 4

do

cd epsin_${i}/ 

for setup in pb1 pb2 pb3

do

cd ${setup}/

for radii in rstd ropt

do

cd ${radii}/

rm -rf RESULTS_receptor RESULTS_ligand RESULTS_complex FINAL_RESULTS MMPBSA_SUMMARY

for a in ligand receptor complex
do

echo "N   VDW      EEL     EPB   ENPOLAR EDISPER  EGAS    SOLV" >> RESULTS_${a}

for i in $(seq $init_frame 1 $n_frames)
do


VDWAALS=`awk '/VDWAALS/ {print $11}' ${a}_${i}.out | tail -1`
EEL=`awk '/EELEC/ {print $3}' ${a}_${i}.out | tail -1`
EPB=`awk '/EPB/ {print $6}' ${a}_${i}.out | tail -1`
ENPOLAR=`awk '/ECAVITY/ {print $2}' ${a}_${i}.out | tail -1`
EDISPER=`awk '/EDISPER/ {print $5}' ${a}_${i}.out | tail -1`
GAS=`echo ${VDWAALS} + ${EEL} | bc`
SOLV=`echo ${EPB} + ${ENPOLAR} + ${EDISPER} | bc`


echo "$i $VDWAALS $EEL $EPB $ENPOLAR $EDISPER $GAS $SOLV" >> RESULTS_${a}
 
done

done


echo "FRAME dG_gas dG_solv dG_bind" >> MMPBSA_SUMMARY



for i in $(seq $init_frame 1 $n_frames)
do

comp_vdw=$(awk -v i=$i '{if ($1==i){print $2}}' RESULTS_complex)
rec_vdw=$(awk -v i=$i '{if ($1==i){print $2}}' RESULTS_receptor)
lig_vdw=$(awk -v i=$i '{if ($1==i){print $2}}' RESULTS_ligand)

comp_elec=$(awk -v i=$i '{if ($1==i){print $3}}' RESULTS_complex)
rec_elec=$(awk -v i=$i '{if ($1==i){print $3}}' RESULTS_receptor)
lig_elec=$(awk -v i=$i '{if ($1==i){print $3}}' RESULTS_ligand)

comp_epb=$(awk -v i=$i '{if ($1==i){print $4}}' RESULTS_complex)
rec_epb=$(awk -v i=$i '{if ($1==i){print $4}}' RESULTS_receptor)
lig_epb=$(awk -v i=$i '{if ($1==i){print $4}}' RESULTS_ligand)

comp_np=$(awk -v i=$i '{if ($1==i){print $5}}' RESULTS_complex)
rec_np=$(awk -v i=$i '{if ($1==i){print $5}}' RESULTS_receptor)
lig_np=$(awk -v i=$i '{if ($1==i){print $5}}' RESULTS_ligand)

comp_dis=$(awk -v i=$i '{if ($1==i){print $6}}' RESULTS_complex)
rec_dis=$(awk -v i=$i '{if ($1==i){print $6}}' RESULTS_receptor)
lig_dis=$(awk -v i=$i '{if ($1==i){print $6}}' RESULTS_ligand)

diff_vdw=`echo ${comp_vdw} - ${rec_vdw} - ${lig_vdw} | bc`
diff_elec=`echo ${comp_elec} - ${rec_elec} - ${lig_elec} | bc`
diff_epb=`echo ${comp_epb} - ${rec_epb} - ${lig_epb} | bc`
diff_np=`echo ${comp_np} - ${rec_np} - ${lig_np} | bc`
diff_dis=`echo ${comp_dis} - ${rec_dis} - ${lig_dis} | bc`
#
delta_G_gas=`echo ${diff_vdw} + ${diff_elec} | bc`
delta_G_solv=`echo ${diff_epb} + ${diff_np} + ${diff_dis} | bc`
delta_G_tot=`echo ${delta_G_gas} + ${delta_G_solv} | bc`

echo "$i $delta_G_gas $delta_G_solv $delta_G_tot" >> MMPBSA_SUMMARY
 
done

dG_tot=$(tail -n +2 MMPBSA_SUMMARY | awk -v tot_frames=${tot_frames} '{sum+=$4;}END{print sum/tot_frames;}')
SD=$(tail -n +2 MMPBSA_SUMMARY | awk '{delta = $4 - avg; avg += delta / NR; mean2 += delta * ($4 - avg); } END { print sqrt(mean2 / NR)}')

echo "dG_tot SD" >> TMP
echo "$dG_tot $SD" >> TMP
paste MMPBSA_SUMMARY TMP > FINAL_RESULTS

echo "FINAL RESULTS"


rm TMP

cd ../
done
cd ../
done
cd ../
done
cd ../
done
cd ../
done
