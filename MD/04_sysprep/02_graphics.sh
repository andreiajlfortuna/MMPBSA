grom=/gromacs/gromacs-2020.6/bin/gmx

 
mkdir graphics


tot_rep=3

for rep in $(seq 1 1 $tot_rep)

do

tpr_md=../03_prod_r${rep}/001.tpr
tpr_xray=../01_min/min1.tpr
xtc=complex_traj_nojump_r${rep}.xtc
cp ../00_build/index.ndx .


echo "[ Binding_site ] " >> index.ndx 
echo "45 46 47 48 51 52 53 54 55 64 65 66 67 68 81" >> index.ndx
echo "85 95 96 97 98 111 112 113 114 115 116 117 118 119 120 " >> index.ndx
echo "160 161 162 163 164 165 170 172 173 174 175 176 " >> index.ndx


index=index.ndx

# RMSD of the full protein using the first MD frame as reference
$grom rms -f $xtc \
          -s $tpr_md \
          -n $index \
          -o rmsd_protein_r${rep}.xvg \
          -fit rot+trans <<EOF
Protein
Protein
EOF

# RMSD of the full protein using the X ray as reference
$grom rms -f $xtc \
          -s $tpr_xray \
          -n $index \
          -o rmsd_protein_xray_r${rep}.xvg \
          -fit rot+trans <<EOF
Protein
Protein
EOF

# RMSD of protein CAs using the first MD frame as reference
$grom rms -f $xtc \
          -s $tpr_md \
          -n $index \
          -o rmsd_CA_r${rep}.xvg \
          -fit rot+trans <<EOF
C-alpha
C-alpha
EOF

# RMSD of protein CAs using the X ray as reference
$grom rms -f $xtc \
          -s $tpr_xray \
          -n $index \
          -o rmsd_CA_xray_r${rep}.xvg \
          -fit rot+trans <<EOF
C-alpha
C-alpha
EOF

# RMSD of the ligand using the first MD frame as reference
$grom rms -f $xtc \
          -s $tpr_md \
          -n $index \
          -o rmsd_ligand_r${rep}.xvg \
          -fit rot+trans <<EOF
MOL
MOL
EOF

# RMSD of the ligand using the X ray as reference
$grom rms -f $xtc \
          -s $tpr_xray \
          -n $index \
          -o rmsd_ligand_xray_r${rep}.xvg \
          -fit rot+trans <<EOF
MOL
MOL
EOF

$grom rms -f $xtc \
          -s $tpr_md \
          -n $index \
          -o rmsd_binding_site_r${rep}.xvg \
          -fit rot+trans <<EOF
Binding_site
Binding_site
EOF

$grom rms -f $xtc \
          -s $tpr_xray \
          -n $index \
          -o rmsd_binding_site_xray_r${rep}.xvg \
          -fit rot+trans <<EOF
Binding_site
Binding_site
EOF

mv *.xvg graphics/.
mv rmsdgraphic_r${rep}.plot graphics/.
cd graphics/

gnuplot rmsdgraphic_r${rep}.plot

cd ../
done

