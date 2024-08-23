#! /bin/bash

# This script generates pdb files from mol2 files with and without EP

export AMBERHOME=/home/pjcosta/bin/amber/amber16

# defines the mol2 file to be used. This corresponds to the mol2
# created using the optimal X-EP distance
for mol2_file in `ls *.mol2`
do
sys=`basename ${mol2_file} .mol2`

###########################################################
# Start running the AMBER stuff
###########################################################

# Look for missing GAFF parameters in the ${sys}_*.mol2 molecule using parmchk
# Besides those of the molecule itself, the bonded and nonbonded parameters
# of the EP will be assined as missing. This is not problematic because
# we will not run MD (in this case the topology has to be sticktly correct). 
# For pbsa calculations we just need coordinates, charges and radii.  

$AMBERHOME/bin/parmchk -i ${mol2_file} -f mol2 -o ${sys}.frcmod

# get the residue name from the mol2 file
resn=`head -2  ${mol2_file} | tail -1`

# create a leap input file. 
# besides loading the GAFF parameters, we also load the {mol2_file} 
# and ${sys}.frcmod for the eventual missing parameters (needed to create the topology).
# Here we have to also set the radii we wan (parse, mbondi)
#
# Then, we give instructions to save a toopology and coordinates file (top,crd)
# 

cat << EOF > leap.in

source leaprc.gaff
mods = loadamberparams ${sys}.frcmod

${resn} = loadmol2 ${mol2_file}

saveAmberParm ${resn} ${sys}.top ${sys}.crd
savepdb ${resn} ${sys}_AMBER.pdb

quit

EOF

$AMBERHOME/bin/tleap -f leap.in

# when using pb1 (parse) and pb2 (mbondi) radii, it is convenient to use a pqr instead
# of a topology file. We create the pqr using the ambpdb tool
$AMBERHOME/bin/ambpdb -p ${sys}.top -c ${sys}.crd > ${sys}.pdb

done

