#! /bin/bash

# This script generates pdb files from mol2 files with and without EP

export AMBERHOME=/home/pjcosta/bin/amber/amber16


# defines the mol2 file to be used. This corresponds to the mol2
# created using the optimal X-EP distance
for pdb in `ls *_aligned_EP1.pdb`

do
mol2_file=`ls ../*.mol2` 

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

# correct EP parameters from https://onlinelibrary.wiley.com/doi/10.1002/jcc.21836

######################################################
# verify if they contain halogens
######################################################

ncl=`cat ${mol2_file} | awk '$6 == "cl"' | wc -l`
nbr=`cat ${mol2_file} | awk '$6 == "br"' | wc -l`
ni=` cat ${mol2_file} | awk '$6 == "i"'  | wc -l`
totX=`echo ${ncl}+${nbr}+${ni} | bc -l`

if [ ${ncl} -gt 0 ]
then  

bond="cl-ep"

## correct BOND parameters
dist=1.948
Kr=600

sed -i "s/${bond}    0.00   0.000/${bond}    ${dist}   ${Kr}/g" ${sys}.frcmod

## correct ANGLE
angle=180
K=150

sed -i "s/${bond}    0.000       0.000/${bond}    ${angle}       ${K}/g" ${sys}.frcmod

fi

if [ ${nbr} -gt 0 ]
then 

bond="br-ep"

## correct BOND parameters
dist=2.02
Kr=600

sed -i "s/${bond}    0.00   0.000/${bond}    ${dist}   ${Kr}/g" ${sys}.frcmod

## correct ANGLE
angle=180
K=150

sed -i "s/${bond}    0.000       0.000/${bond}    ${angle}       ${K}/g" ${sys}.frcmod
fi

if [ ${ni} -gt 0 ]
then  

bond="i -ep"

## correct BOND parameters
dist=2.15
Kr=600

sed -i "s/${bond}    0.00   0.000/${bond}    ${dist}   ${Kr}/g" ${sys}.frcmod

## correct ANGLE
angle=180
K=150

sed -i "s/${bond}    0.000       0.000/${bond}    ${angle}       ${K}/g" ${sys}.frcmod

fi

sed -i "s/ep          0.0000  0.0000/ep          1.0000  0.0000/g" ${sys}.frcmod


# get the residue name from the mol2 file
resn=`head -2  ${mol2_file} | tail -1`


name=`basename ${pdb} .pdb`
# create a leap input file. 
# besides loading the GAFF parameters, we also load the {mol2_file} 
# and ${sys}.frcmod for the eventual missing parameters (needed to create the topology).
# Here we have to also set the radii we wan (parse, mbondi)
#
# Then, we give instructions to save a toopology and coordinates file (top,crd)
# 

cat << EOF > leap.in

source oldff/leaprc.ff99SBildn #Source leaprc file for amber99sb protein force field
source leaprc.gaff #Source leaprc file for gaff
source leaprc.water.tip3p #Source leaprc file for TIP3P water model
mods = loadamberparams ${sys}.frcmod #Source the missing parameters

set default PBRadii parse

${resn} = loadmol2 ${mol2_file} # load the ligand residue
mol = loadpdb ${pdb} #Load PDB file for protein-ligand complex

saveAmberParm mol ${name}.prmtop ${name}.inpcrd

addIons mol Na+ 0
addIons mol Cl- 0

solvatebox mol TIP3PBOX 12.0  #solvate system
saveAmberParm mol ${name}_solvated_parse.prmtop ${name}_solvated_parse.inpcrd
savepdb mol ${name}_solvated_parse.pdb

quit

EOF

$AMBERHOME/bin/tleap -f leap.in

cat << EOF > leap.in
source oldff/leaprc.ff99SBildn  #Source leaprc file for ff99SB-ildn protein force field
source leaprc.gaff #Source leaprc file for gaff
source leaprc.water.tip3p #Source leaprc file for TIP3P water model
mods = loadamberparams ${sys}.frcmod #Source the missing parameters

set default PBRadii mbondi

${resn} = loadmol2 ${mol2_file} # load the ligand residue
mol = loadpdb ${pdb} #Load PDB file for protein-ligand complex

addIons mol Na+ 0
addIons mol Cl- 0

solvatebox mol TIP3PBOX 12.0  #solvate system
saveAmberParm mol ${name}_solvated_mbondi.prmtop ${name}_solvated_mbondi.inpcrd
savepdb mol ${name}_solvated_mbondi.pdb

quit

EOF

$AMBERHOME/bin/tleap -f leap.in

done
