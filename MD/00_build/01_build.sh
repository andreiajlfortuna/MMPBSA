#!/bin/bash -e
 
usage="Usage: 
      --------------------------------------------\n
       
       Protein_name
       Ligand_name 
       Be careful with dEP, check its value in this script "

# Parse arguments
if [ $# != 2 ]; then
    echo -e $usage >/dev/stderr
    exit 1
fi

grom=/gromacs/gromacs-2020.6-GPU/bin/gmx
export AMBERHOME=/home/pjcosta/bin/amber/amber16

##########################################
# Read input variables
##########################################
sys=$1
lig=$2
####################

######################################################
# verify halogens and EPs
######################################################
# for this library, some ligands possess two different halogen types 
# therefore, we need to check the number of halogens and their type 
# the EPs are added according to this info (if two halogen types then: dEP1 and dEP2)


mol2=`ls *.mol2`

ncl=`cat ${mol2} | awk '$6 == "cl"' | wc -l`
nbr=`cat ${mol2} | awk '$6 == "br"' | wc -l`
ni=` cat ${mol2} | awk '$6 == "i"'  | wc -l`
totX=`echo ${ncl}+${nbr}+${ni} | bc -l`

if [ ${ncl} -gt 0 -a ${nbr} -eq 0 -a ${ni} -eq 0 ]
then
echo "Molecule ${bname} has ${ncl} Chlorine atoms." >&2
Xtype1=CL 
dEP1=1.948
nX1=${ncl}
nX2=0
dEP2=0
elif [ ${ncl} -eq 0 -a ${nbr} -gt 0 -a ${ni} -eq 0 ]
then
echo "Molecule ${bname} has ${nbr} Bromine atoms." >&2
Xtype1=BR
dEP1=2.02
nX1=${nbr}
nX2=0
dEP2=0
elif [ ${ncl} -eq 0 -a ${nbr} -eq 0 -a ${ni} -gt 0 ]
then
echo "Molecule ${bname} has ${ni} Iodine atoms." >&2
Xtype1=I
nX1=${ni}
dEP1=2.15
nX2=0
dEP2=0
elif [ ${ncl} -gt 0 -a ${nbr} -gt 0 -a ${ni} -eq 0 ]
then
echo "Molecule ${bname} has ${ncl} Chlorine atoms and ${nbr} Bromine atoms." >&2
Xtype1=CL
nX1=${ncl}
dEP1=1.948
Xtype2=BR
nX2=${nbr}
dEP2=2.02
elif [ ${ncl} -eq 0 -a ${nbr} -gt 0 -a ${ni} -gt 0 ]
then
echo "Molecule ${bname} has ${nbr} bromine atoms and ${ni} Iodine atoms." >&2
Xtype1=BR
nX1=${nbr}
dEP1=2.02
Xtype2=I
nX2=${ni}
dEP2=2.15
elif [ ${ncl} -gt 0 -a ${nbr} -eq 0 -a ${ni} -gt 0 ]
then
Xtype1=CL
nX1=${ncl}
dEP1=1.948
Xtype2=I
nX2=${ni}
dEP2=2.15
echo "Molecule ${bname} has ${ncl} Chlorine atoms and ${ni} Iodine atoms." >&2
fi
echo "totX is ${totX}"
echo "dEPs are $dEP1 and $dEP2"


pdblig=`ls *EP_aligned.pdb`

$grom editconf -f ${pdblig} -o ${lig}.gro

frcmod=`ls *.frcmod`

cat << EOF > leap.in
source leaprc.gaff #Source leaprc file for gaff
mods = loadamberparams ${frcmod} #Source the missing parameters

mol = loadmol2 ${mol2}
saveAmberParm mol ${lig}.top ${lig}.crd
quit
EOF

$AMBERHOME/bin/tleap -f leap.in

cp /home/pjcosta/bin/acpype.py . 

python3 ./acpype.py -p ${lig}.top -x ${lig}.crd
mv MOL_GMX.gro ${lig}_GMX.gro
mv MOL_GMX.top ${lig}_GMX.top

cp ${lig}_GMX.top ${lig}_GMX.top.bak

#######################################################
# Modifies the GMX topology files when EPs are present
#######################################################


#######################################################
# Remove bonds, angles, dihedrals for EPs
#######################################################
sed -i '/ - EP/d;/EP-/d;/-    EP/d;/EP -/d' ${lig}_GMX.top

########################################################
# In GMX, EPs are represented as virtual sites
# Add virtual site for each halogen
#########################################################

# Identifies the halogens


for nX in $(sed -n '/bonds/,/pairs/p' ${lig}_GMX.top.bak | awk -v Xtype1=${Xtype1} '{if ($7~Xtype1) print $1}')
do

nC=`sed -n '/bonds/,/pairs/p' ${lig}_GMX.top | awk -v nX=$nX '{if ($1 == nX) print $2; else if ($2 == nX) print $1}'`
nEP=`sed -n '/bonds/,/pairs/p' ${lig}_GMX.top.bak | grep EP | awk -v nX=$nX '{if ($1 == nX) print $2; else if ($2 == nX) print $1}'`
Cdist=`sed -n '/bonds/,/pairs/p' ${lig}_GMX.top | awk -v nX=$nX '{if ($1 == nX || $2 == nX) print $4}'`
epdist=`awk -v xep=${dEP1} 'BEGIN {print -xep/10}'`

echo ${nEP} ${nX} ${nC} 2 ${epdist} >>  VSITE.${lig}
done 

if [ ${nX2} -gt 0 ]
then

for nX in $(sed -n '/bonds/,/pairs/p' ${lig}_GMX.top.bak | awk -v Xtype2=${Xtype2} '{if ($7~Xtype2) print $1}')
do

nC=`sed -n '/bonds/,/pairs/p' ${lig}_GMX.top | awk -v nX=$nX '{if ($1 == nX) print $2; else if ($2 == nX) print $1}'`
nEP=`sed -n '/bonds/,/pairs/p' ${lig}_GMX.top.bak | grep EP | awk -v nX=$nX '{if ($1 == nX) print $2; else if ($2 == nX) print $1}'`
Cdist=`sed -n '/bonds/,/pairs/p' ${lig}_GMX.top | awk -v nX=$nX '{if ($1 == nX || $2 == nX) print $4}'`
epdist=`awk -v xep=${dEP2} 'BEGIN {print -xep/10}'`
 
echo ${nEP} ${nX} ${nC} 2 ${epdist} >>  VSITE.${lig}
done 
fi
# write virtual site block
# we will futuraly use the new 2fd type

sed -i '1 i\[ virtual_sites2 ]' VSITE.${lig}
sed -i '1 i\ ' VSITE.${lig}

sed -i "/qtot 0.000/r VSITE.${lig}" ${lig}_GMX.top
sed -i "/qtot -0.000/r VSITE.${lig}" ${lig}_GMX.top
rm -rf VSITE.${lig}
rm -rf em.mdp md.mdp

#create ligand.itp file and gaff_atom_type.itp file
cp ${lig}_GMX.top ${lig}.itp

awk '/atomtypes/,/moleculetype/' ${lig}_GMX.top | head -n -1 > gaff_atom_types.itp

n=$(awk '/defaults/,/moleculetype/' ${lig}_GMX.top  | wc -l)
nline=$((n+1))
sed -i "3,${nline}d" ${lig}.itp 
NLf=`wc -l ${lig}.itp | awk '{print $1}'`
NLi=$((NLf-6))
sed -i "${NLi},${NLf}d" ${lig}.itp
 
#run pb2gmx to create top
pdbsys=`ls *chainA_aligned.pdb`

############################# 
# PROTEIN PROTONATION STATE #
############################# 
# CHECK PROTONATION STATES USING: https://pypka.org/
# for this case we have to be careful with:
## 1 - HIE ; 99, 142, 148, 154, 160, 177, 230, 233, 270, 285, 315,  
## 0 - HID ; 303
$grom pdb2gmx -f ${pdbsys} -p ${sys}.top -o ${sys}.gro -ff amber99sb-ildn -water tip3p -ignh -merge all -renum -ter -his <<EOF
1 
1 
1
1
1
1
1
1
1
1
0
1
EOF


# Adds ${ligand}.itp to the topology of the protein. 
sed -z "s/\#include \"posre.itp\"*\n#endif/\#include \"posre.itp\"\n\#endif\n\n\#include \"${lig}.itp\"/" ${sys}.top > ${sys}-${lig}.top
# Adds the ligand to the molecules listing.
res=`grep -A1 ";name" ${lig}.itp | tail -n1 | awk '{print $1}'`
echo "${res}          1" >> ${sys}-${lig}.top
# Adds the atom types to the topology file
sed -i "/#include \"amber99sb-ildn.ff\/forcefield.itp\"/a #include \"gaff_atom_types.itp\"" ${sys}-${lig}.top


#add the ligand coordinates to the original protein GRO file, gerated by pdb2gmx
#ligandname=MOL

head -n -1 ${sys}.gro > aux_prot
    tail -n 1 ${sys}.gro > aux_box
    ligandname=`awk 'NR==1 {print $4}' ${pdblig}`
    egrep ${ligandname} ${lig}.gro >> aux_prot
    cat aux_prot aux_box | awk -v tot=`awk 'END{print NR-2}' aux_prot` \
    '{if (NR==2){print tot}else{print $0}}' > ${sys}-${lig}.gro
    rm aux*
    rm -f *~ *# .*~ .*# aux*


# Create a simulation box for each protein-ligand system
    # " A rhombic-dodecahedral simulation box was used"
    $grom editconf -f ${sys}-${lig}.gro -o ${sys}-${lig}_dode.gro -bt dodecahedron -d 1.0 -c -resnr 1
    # Solvate with water molecules
    $grom solvate -cp ${sys}-${lig}_dode.gro -cs spc216.gro -p ${sys}-${lig}.top -o ${sys}-${lig}_solv.gro
    $grom make_ndx -f ${sys}-${lig}_solv.gro -o index.ndx <<EOF
    q
EOF
    #Temp mdp to use in grompp - Default values will be used
    echo ";" >aux.mdp
    # Create tpr file 
    $grom grompp -f aux.mdp -c ${sys}-${lig}_solv.gro -p ${sys}-${lig}.top -n index.ndx -o ${sys}-${lig}_genion.tpr -maxwarn 10

    # add ions automatically by nutralizing the system. the -neutral flag calculates and adds automagically the needed ions
    $grom genion -s ${sys}-${lig}_genion.tpr -n index.ndx -o ${sys}-${lig}_solv_ion.gro -p ${sys}-${lig}.top -pname NA -nname CL -neutral<<EOF
    SOL
EOF
rm aux* mdout.mdp

# make the final index
$grom make_ndx -f ${sys}-${lig}_solv_ion.gro -o ${sys}-${lig}_index.ndx <<EOF
del 2-12
del 3
del 4-6
1|4
name 7 Protein_ligand
3|5
name 8 SOL
q
EOF

rm -f *~ *# .*~ .*# aux* mdout.mdp
 
