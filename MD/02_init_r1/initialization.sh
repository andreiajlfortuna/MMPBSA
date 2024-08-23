#!/bin/bash -e
 
usage="Usage: 
      --------------------------------------------\n
       
       Protein name
       Ligand name                             "

# Parse arguments
if [ $# != 2 ]; then
    echo -e $usage >/dev/stderr
    exit 1
fi

##########################################
# Read input variables
##########################################
sys=$1
lig=$2
####################


grom=/gromacs/gromacs-2020.6/bin/gmx

top=../00_build/${sys}-${lig}.top
index=../00_build/${sys}-${lig}_index.ndx
prev=../01_min/min2.gro
curr=i100
CPUs=4
## Make the tpr file for init1 (NVT)
## First initialization procedure (init1) ##
$grom grompp -f ${curr}.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -o ${curr}.tpr \
      -r ${prev} \
      -maxwarn 10 
      
# Run initiation
# The -nt flag defines the number of threads, or CPU cores in order
# to perform the MD segment using multiple CPUs (and GPU if available).
$grom mdrun -s ${curr}.tpr \
        -x ${curr}.xtc \
        -c ${curr}.gro \
        -e ${curr}.edr \
        -g ${curr}.log \
	-nice 19 -v \
	-nt $CPUs -pin auto

$grom trjconv -f ${curr}.gro -s ${curr}.tpr -n ${index} -o ${curr}.pdb -pbc mol -ur compact<<EOF
System
EOF

## Second initiation procedure ###
# Updated block names and input configuration
prev=./i100.gro
curr=i200

## Make the tpr file for init2 (NPT)
$grom grompp -f ${curr}.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -o ${curr}.tpr \
      -r ${prev} \
      -maxwarn 10
      

# Run initiation
$grom mdrun -nt $CPUs -pin auto\
        -s ${curr}.tpr \
        -x ${curr}.xtc \
        -c ${curr}.gro \
        -e ${curr}.edr \
        -g ${curr}.log \
	-nice 19 -v


$grom trjconv -f ${curr}.gro -s ${curr}.tpr -n ${index} -o ${curr}.pdb -pbc mol -ur compact<<EOF
System
EOF

echo Done

exit 0

rm -f *~ *# .*~ .*# 
