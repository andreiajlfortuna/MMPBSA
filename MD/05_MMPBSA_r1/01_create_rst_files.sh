
export AMBERHOME=/home/pjcosta/bin/amber/amber20-with-ep-new/
source /home/pjcosta/bin/amber/amber20-with-ep-new/amber.sh

usage="Usage: 
      --------------------------------------------\n
       
       replicate number
       (Be careful with the n_frames and init_frames defined within the script) "
# Parse arguments
if [ $# != 1 ]; then
    echo -e $usage >/dev/stderr
    exit 1
fi

rep=$1

n_frames=1000
init_frame=1


cat << EOF > cpptraj.in
parm ../../04_sysprep/complex_mbondi.prmtop
trajin ../../04_sysprep/complex_traj_nojump_r${rep}.xtc
rmsd mass first
outtraj complex.mdcrd onlyframe ${init_frame}-${n_frames} nobox
strip :MOL
outtraj receptor.mdcrd onlyframe ${init_frame}-${n_frames} nobox
unstrip
rmsd mass first
strip !:MOL
outtraj ligand.mdcrd onlyframe ${init_frame}-${n_frames} nobox
EOF

$AMBERHOME/bin/cpptraj -i cpptraj.in

for a in ligand receptor complex
do

cat <<EOF > cpptraj_${a}.in
parm ../../04_sysprep/${a}_mbondi.prmtop
trajin ${a}.mdcrd
EOF


for i in $(seq $init_frame 1 $n_frames)
do

echo "outtraj ${a}_${i}.rst onlyframes ${i}-${i} nobox" >> cpptraj_${a}.in

done

$AMBERHOME/bin/cpptraj -i cpptraj_${a}.in

done
