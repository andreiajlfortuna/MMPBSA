#!/bin/bash 
# Variable to invoke the program GROMACS
grom=/gromacs/gromacs-2020.6/bin/gmx

tot_rep=3



tot_rep=3
for rep in $(seq 1 1 $tot_rep)
do

# Input files:

gzip -d ../03_prod_r${rep}/001.tpr.gz 


done



for rep in $(seq 1 1 $tot_rep)

do

# Input files:



tpr=../03_prod_r${rep}/001.tpr

index=../00_build/*_index.ndx

 
########################
### GET TRAJ_ALL.XTC ###
########################

        # concatenate the traj
        echo "echo concatenate the traj"
        $grom trjcat -f ../03_prod_r${rep}/*.xtc \
                    -o concatenated_r${rep}.xtc \
                    -n ${index} <<EOF
        Protein_ligand        
EOF



# Create the xtc file with the trajectories
$grom trjconv -f concatenated_r${rep}.xtc \
      -s $tpr \
      -n $index \
      -o traj_all_nojump_r${rep}.xtc \
      -center -ur compact -pbc nojump <<EOF
Protein
Protein_ligand
EOF


# Create the xtc file fitted for complex
$grom trjconv -f traj_all_nojump_r${rep}.xtc \
      -s $tpr \
      -n $index \
      -o complex_traj_nojump_r${rep}.xtc \
      -fit rot+trans<<EOF
Protein
Protein_ligand
EOF

#create xtc file for receptor
$grom trjconv -f complex_traj_nojump_r${rep}.xtc \
      -s $tpr \
      -n $index \
      -o receptor_traj_nojump_r${rep}.xtc<<EOF
Protein
EOF

#check if they are ok
$grom trjconv -f complex_traj_nojump_r${rep}.xtc \
      -s $tpr  \
      -n $index \
      -o complex_traj_nojump-skip30_r${rep}.pdb \
      -skip 30 <<EOF
Protein_ligand
EOF


#create xtc file for ligand
$grom trjconv -f complex_traj_nojump_r${rep}.xtc \
      -s $tpr \
      -n $index \
      -o ligand_traj_nojump_r${rep}.pdb<<EOF
2
EOF

#check if everything is ok
$grom trjconv -f complex_traj_nojump_r${rep}.xtc \
      -s $tpr  \
      -n $index \
      -o complex_traj_nojump-skip30_r${rep}.pdb \
      -skip 30 <<EOF
Protein_ligand
EOF


 
done
rm -f *~ *# .*~ .*# 
 
