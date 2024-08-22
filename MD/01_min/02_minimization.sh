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

grom=/gromacs/gromacs-2020.6-GPU/bin/gmx

# System name to be used throughout this step

# Input files needed:
top=../00_build/${sys}-${lig}.top
index=../00_build/${sys}-${lig}_index.ndx
prev=../00_build/${sys}-${lig}_solv_ion.gro

# Variable defining the name for the first step of the minimization
curr=min1

# Number of CPU cores to be used in the calculation
CPUs=8

### First minimization procedure ###

## Make the tpr file for Minimization
$grom grompp -f ${curr}.mdp \
      -po ${curr}_out.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -pp ${curr}_processed.top \
      -o ${curr}.tpr \
      -maxwarn 1000

# Run Minimization
$grom mdrun -s ${curr}.tpr \
      -x ${curr}.xtc \
      -c ${curr}.gro \
      -e ${curr}.edr \
      -g ${curr}.log \
      -v -nice 19 \
      -nt $CPUs -pin auto


### Second minimization procedure ###

# Updated block names and input configuration
prev=./min1.gro
curr=min2

# Make the tpr file for the Minimization
$grom grompp -f ${curr}.mdp \
      -po ${curr}_out.mdp \
      -c ${prev} \
      -n ${index} \
      -p ${top} \
      -pp ${curr}_processed.top \
      -o ${curr}.tpr \
      -maxwarn 1000

# Run Minimization
$grom mdrun -s ${curr}.tpr \
      -x ${curr}.xtc \
      -c ${curr}.gro \
      -e ${curr}.edr \
      -g ${curr}.log \
      -v -nice 19 \
      -nt $CPUs -pin auto

# cleanup
rm -f *~ *# .*~ .*# traj.trr

$grom trjconv -f ${curr}.gro -s ${curr}.tpr -n ${index} \
	-o ${sys}_${curr}.pdb -pbc mol -ur compact<<EOF
0
EOF
