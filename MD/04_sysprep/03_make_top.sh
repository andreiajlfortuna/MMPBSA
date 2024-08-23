#!/bin/bash -e
# Variable to invoke the program GROMACS
grom=/gromacs/gromacs-2020.6/bin/gmx
export AMBERHOME=/home/pjcosta/bin/amber/amber20-with-ep
source /home/pjcosta/bin/amber/amber20-with-ep/amber.sh

tpr=../03_prod_r1/001.tpr
index=../00_build/*_index.ndx

#make index
${grom} make_ndx -n ${index} -o _GMXMMPBSA_COM_index.ndx<<EOF
del 3-8
del 0
0|1
name 2 GMXMMPBSA_REC_GMXMMPBSA_LIG
q
EOF

#make pdb of the complex
${grom} trjconv -f complex_traj_nojump_r1.xtc -s ${tpr} -o _GMXMMPBSA_COM.pdb -n ${index} -dump 0 <<EOF
Protein_Ligand
EOF
#make pdb of the protein
${grom} trjconv -f complex_traj_nojump_r1.xtc -s ${tpr} -o _GMXMMPBSA_REC.pdb -n ${index} -dump 0 <<EOF
PRotein
EOF

#remove H
#awk '{if ($11!="H"){print $0}}' _GMXMMPBSA_REC.pdb >> _GMXMMPBSA_REC_withoutH.pdb
${AMBERHOME}/bin/pdb4amber -i _GMXMMPBSA_REC.pdb -o _GMXMMPBSA_REC_noH.pdb --nohyd

#prepare the topology 
#replace OC1 and OC2 for O and OXT
sed -i 's/OC1/O  /g' _GMXMMPBSA_REC_noH.pdb
sed -i 's/OC2/OXT/g' _GMXMMPBSA_REC_noH.pdb

#replace CD for CD1 when residue=ILE
sed -i 's/CD  ILE/CD1 ILE/g' _GMXMMPBSA_REC_noH.pdb

#correct last residue atomic number (falta a coluna A)
sed -i "s/TER    $lastres/TER    $correctres/g" _GMXMMPBSA_REC_noH.pdb

#make pdb of the ligand
${grom} trjconv -f complex_traj_nojump_r1.xtc -s ${tpr} -o _GMXMMPBSA_LIG.pdb -n _GMXMMPBSA_COM_index.ndx -dump 0 <<EOF
1
EOF

# correct HIS residues; 
sed -i "s/HIS A 303/HID A 303/g" _GMXMMPBSA_REC_noH.pdb

#create topologies

frcmod=$(ls ../00_build/*.frcmod)
mol2=$(ls ../00_build/*.mol2)
cat << EOF > leap_mbondi.in

source oldff/leaprc.ff99SBildn #Source leaprc file for ff99SB protein force field
source leaprc.gaff #Source leaprc file for gaff
source leaprc.water.tip3p #Source leaprc file for TIP3P water model
mods = loadamberparams ${frcmod}

set default PBRadii mbondi

REC1 = loadpdb _GMXMMPBSA_REC_noH.pdb

LIG1 = loadmol2 ${mol2}

loadamberparams ${frcmod}

check LIG1

saveamberparm LIG1 ligand_mbondi.prmtop _GMXMMPBSA_LIG.inpcrd

REC_OUT = combine { REC1 }

saveamberparm REC_OUT receptor_mbondi.prmtop _GMXMMPBSA_REC.inpcrd

COM_OUT = combine { REC1 LIG1 }

saveamberparm COM_OUT complex_mbondi.prmtop _GMXMMPBSA_COM.inpcrd

quit

EOF

$AMBERHOME/bin/tleap -f leap_mbondi.in

cat << EOF > leap_parse.in

source oldff/leaprc.ff99SBildn #Source leaprc file for ff99SB protein force field
source leaprc.gaff #Source leaprc file for gaff
source leaprc.water.tip3p #Source leaprc file for TIP3P water model
mods = loadamberparams ${frcmod}

set default PBRadii parse

REC1 = loadpdb _GMXMMPBSA_REC_noH.pdb

LIG1 = loadmol2 ${mol2}

loadamberparams ${frcmod}

check LIG1

saveamberparm LIG1 ligand_parse.prmtop _GMXMMPBSA_LIG.inpcrd

REC_OUT = combine { REC1 }

saveamberparm REC_OUT receptor_parse.prmtop _GMXMMPBSA_REC.inpcrd

COM_OUT = combine { REC1 LIG1 }

saveamberparm COM_OUT complex_parse.prmtop _GMXMMPBSA_COM.inpcrd

quit

EOF

$AMBERHOME/bin/tleap -f leap_parse.in
