#!/bin/bash 

export AMBERHOME=/home/pjcosta/bin/amber/amber20-with-ep/
source /home/pjcosta/bin/amber/amber20-with-ep/amber.sh


for i in 2

do

cd epsin_${i}/ 

for setup in pb1 pb2 pb3

do

cd ${setup}/

for radii in rstd ropt

do

cd ${radii}/

if [ ${radii} == "rstd" ]
then
rCl=1.700000000000
rBr=1.850000000000
rI=1.980000000000

elif [ ${radii} == "ropt" ]
then

if [ ${setup} == "pb1" ]
then 
rCl=2.370000000000
rBr=2.510000000000
rI=2.730000000000

elif [ ${setup} == "pb2" ]
then 
rCl=2.120000000000
rBr=2.350000000000
rI=2.580000000000

elif [ ${setup} == "pb3" ]
then 
rCl=2.340000000000
rBr=2.540000000000
rI=2.650000000000

fi

fi




######################################################
# verify halogens
######################################################
mol2_file=`ls ../../../../../*.mol2`

ncl=`cat ${mol2_file} | awk '$6 == "cl"' | wc -l`
nbr=`cat ${mol2_file} | awk '$6 == "br"' | wc -l`
ni=` cat ${mol2_file} | awk '$6 == "i"'  | wc -l`
totX=`echo ${ncl}+${nbr}+${ni} | bc -l`

echo "Molecule ${bname} has ${ncl} Chlorine atoms and ${ni} Iodine atoms." >&2

echo "totX is ${totX}"

for a in complex ligand
do

rst=../../../rstfiles/${a}_101.rst
$AMBERHOME/bin/ambpdb -p ../../../../04_sysprep/${a}_parse.prmtop -c ${rst} -pqr > ${a}.pqr


# from Rafael's paper 10.1021/acs.jctc.9b00106

sed -i "s/1.5000       I/1.9800       I/g" ${a}.pqr
sed -i "s/1.5000      BR/1.8500      BR/g" ${a}.pqr
sed -i "s/1.5000      CL/1.7000      CL/g" ${a}.pqr
 
# Strangely, the formated column pqr file outputed from ambpdb is not properly
# read by pbsa. This is because pbsa reads a free-format pqr (no column format) 
# Se, we correct the pqr
awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' ${a}.pqr > ${a}_mod.pqr

# Also, the pqr file outputed from ambpdb does not contain the EPs ...
# So, we must add the EPs with their coordinates and charges taken from
# the mol2 file; the EP PB radii is set to zero

# Total number of atoms
ntot=`grep ATOM ${a}_mod.pqr | wc -l`
# Total number of EPs
 
cp ../../../../04_sysprep/${a}_parse.prmtop ${a}_mod.prmtop

if [ ${ncl} -gt 0 ]
then

# define rEP as an arbitrary number and correct pb radii of iodine (only for dGnonpolar)

# change rEP and rX in the topology file
  for j in $(seq 1 1 ${ncl})
  do
  
  
  Cl=`grep "Cl${j} " ${a}_mod.pqr | awk '{print $2}'`

  
  awk -i inplace -v rCl=${rCl} -v Cl=${Cl} 'BEGIN {ref=0;count=0}{
  if (ref==0){print $0}
  else if (ref==1){print $0;ref=2}
  else if (ref==2 && $0 ~ /FLAG/){print $0;ref=0}
  else {
  for (i=1;i<=NF;i++){
  if      ((count+i)==Cl) {printf "%16.8e", rCl}
    else                  {printf "%16.8e", $i}
  }
  print ""
  count = count + NF
  }
  if ($0 ~ /FLAG RADII/){ref=1}
  }' ${a}_mod.prmtop
  
  done
    
  /bin/rm -rf ${a}_mod-TMP.prmtop

fi

if [ ${ni} -gt 0 ]
then

# define rEP as an arbitrary number and correct pb radii of iodine (only for dGnonpolar)


# change rEP and rX in the topology file
  for j in $(seq 1 1 ${ni})
  do
 
  I=`grep "I${j} " ${a}_mod.pqr | awk '{print $2}'`

  
  awk -i inplace -v rI=${rI} -v I=${I} 'BEGIN {ref=0;count=0}{
  if (ref==0){print $0}
  else if (ref==1){print $0;ref=2}
  else if (ref==2 && $0 ~ /FLAG/){print $0;ref=0}
  else {
  for (i=1;i<=NF;i++){
  if      ((count+i)==I) {printf "%16.8e", rI}
    else                  {printf "%16.8e", $i}
  }
  print ""
  count = count + NF
  }
  if ($0 ~ /FLAG RADII/){ref=1}
  }' ${a}_mod.prmtop
  
  done
  
    /bin/rm -rf ${a}_mod-TMP.prmtop

fi

if [ ${nbr} -gt 0 ]
then

# define rEP as an arbitrary number and correct pb radii of iodine (only for dGnonpolar)

# change rEP and rX in the topology file
  for j in $(seq 1 1 ${nbr})
  do
  
  
  Br=`grep "Br${j} " ${a}_mod.pqr | awk '{print $2}'`

  
  awk -i inplace -v rBr=${rBr} -v Br=${Br} 'BEGIN {ref=0;count=0}{
  if (ref==0){print $0}
  else if (ref==1){print $0;ref=2}
  else if (ref==2 && $0 ~ /FLAG/){print $0;ref=0}
  else {
  for (i=1;i<=NF;i++){
  if      ((count+i)==Br) {printf "%16.8e", rBr}
    else                  {printf "%16.8e", $i}
  }
  print ""
  count = count + NF
  }
  if ($0 ~ /FLAG RADII/){ref=1}
  }' ${a}_mod.prmtop
  
  done
  
  
  /bin/rm -rf ${a}_mod-TMP.prmtop

fi

 

rm -rf ${a}_TMP.prmtop
mv ${a}_mod.prmtop ${a}.prmtop

cp ../../../../04_sysprep/receptor_parse.prmtop receptor.prmtop

done

cd ../

done 

cd ../

done
cd ../
done
