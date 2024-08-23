Obtaining RESP charges: no off-center charges
Atomic partial charges are derived following the restrained ESP (RESP) procedure, using antechamber
from AmberTools, which is a main program that calls other programs sequentially (e.g. atomtype,
am1bcc, bondtype, espgen, respgen, prepgen). By running antechamber for 2-iodophenol without off-
center charges, we will not only obtain RESP charges for the molecule (without EP), but also generate
template files to add the off-center charge (EP).

export AMBERHOME=/home/pjcosta/bin/amber/amber16
for file in *.log
do
bname=`basename ${file} .log`
${AMBERHOME}/bin/antechamber -i ${bname}.log -fi gout -o ${bname}.mol2 -fo mol2 -c resp -nc 0 

mv ANTECHAMBER.ESP      ${bname}.ESP
mv ANTECHAMBER_RESP1.IN ${bname}_RESP1.IN
#mv ANTECHAMBER_RESP1.IN ${bname}_RESP1.IN.placebo
/bin/rm ANTECHAMBER* QOUT qout punch ATOMTYPE.INF esout

#create pdb from mol2 files
export AMBERHOME=/home/pjcosta/bin/amber/amber16
mol2=`ls *-RESP.mol2`
for mol2 in *-RESP.mol2
do
bname="${mol2%.*}"
${AMBERHOME}/bin/antechamber -i ${mol2} -fi mol2 -o ${bname}.pdb -fo pdb
done
