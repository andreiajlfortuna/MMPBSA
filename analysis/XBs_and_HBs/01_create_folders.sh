#!/bin/bash 

usage="Usage: 
      --------------------------------------------\n
       
       METHOD (e.g. EP1, EP2, EP3, no_EP)"

# Parse arguments
if [ $# != 1 ]; then
    echo -e $usage >/dev/stderr
    exit 1
fi

method=$1

grom=/gromacs/gromacs-2020.6/bin/gmx


for rec in $(tail -n +2 ../dGexp_setA | awk '{print $1}')

do

lig=$(awk -v rec=${rec} '($1~rec){print $2}' ../dGexp_setA)

mkdir ${rec}_${lig}

cd ${rec}_${lig}/


cp /home/afortuna/mm-pbsa-ck2/systems_build/set_A/${rec}_${lig}_${method}/MD/00_build/${lig}.top .
cp /home/afortuna/mm-pbsa-ck2/systems_build/set_A/${rec}_${lig}_${method}/MD/00_build/${lig}.itp .
cp /home/afortuna/mm-pbsa-ck2/systems_build/set_A/${rec}_${lig}_${method}/MD/00_build/index.ndx .
dir=/home/afortuna/mm-pbsa-ck2/systems_build/set_A/XBs_HBs_count/scripts_count_XBs

mkdir -p count_XBs

### this is a solvated gro and trajectory doesn't have waters; remove waters and correct atom numbers
cp /home/afortuna/mm-pbsa-ck2/systems_build/set_A/${rec}_${lig}_${method}/MD/03_prod_r1/001.gro .
sed -i '/SOL/d' 001.gro
sed -i '/CL/d' 001.gro
 

n_old=$(awk '(NR==2){print $1}' 001.gro)
n_new=$(tail -2 001.gro | head -1 | awk '{print $3}') 

sed -i "s/${n_old}/${n_new}/g" 001.gro



tot_rep=3


for rep in $(seq 1 1 $tot_rep)

do

traj=/home/afortuna/mm-pbsa-ck2/systems_build/set_A/${rec}_${lig}_${method}/MD/04_sysprep/complex_traj_nojump_r${rep}.xtc 

##################################################################
####################### create traj ##############################
##################################################################

$grom trjconv -f ${traj} \
      -o traj_10ns_r${rep}.xtc \
      -b 10 -e 10000

done

cd ../
echo "$rec $lig"

done
