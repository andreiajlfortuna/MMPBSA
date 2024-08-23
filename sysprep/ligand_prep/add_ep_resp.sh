#! /bin/bash

export AMBERHOME=/home/pjcosta/bin/amber/amber16

##########################################
# The X-EP distance is given in the input
##########################################
dEP=$1
####################

for file in *.log
do
bname=`basename ${file} .log`

######################################################
# generate initial ESP and mol2 files
######################################################
${AMBERHOME}/bin/antechamber -i ${bname}.log -fi gout -o ${bname}.mol2 -fo mol2 -c resp -nc 0 > /dev/null 2>&1

mv ANTECHAMBER.ESP      ${bname}.ESP
mv ANTECHAMBER_RESP1.IN ${bname}_RESP1.IN
#mv ANTECHAMBER_RESP1.IN ${bname}_RESP1.IN.placebo
/bin/rm ANTECHAMBER* QOUT qout punch ATOMTYPE.INF esout

######################################################
# verify if they contain halogens
######################################################

ncl=`cat ${bname}.mol2 | awk '$6 == "cl"' | wc -l`
nbr=`cat ${bname}.mol2 | awk '$6 == "br"' | wc -l`
ni=` cat ${bname}.mol2 | awk '$6 == "i"'  | wc -l`
totX=`echo ${ncl}+${nbr}+${ni} | bc -l`
if [ ${ncl} -gt 0 -a ${nbr} -eq 0 -a ${ni} -eq 0 ]
then
echo "Molecule ${bname} has ${ncl} Chlorine atoms." >&2
Xtype=Cl
elif [ ${ncl} -eq 0 -a ${nbr} -gt 0 -a ${ni} -eq 0 ]
then
echo "Molecule ${bname} has ${nbr} Bromine atoms." >&2
Xtype=Br
elif [ ${ncl} -eq 0 -a ${nbr} -eq 0 -a ${ni} -gt 0 ]
then
echo "Molecule ${bname} has ${ni} Iodine atoms." >&2
Xtype=I
fi
echo "${totX}|${Xtype}"

##########################################################
# Adds EPs on halogenated molecules
##########################################################
echo ${totX}
if [[ $totX -eq 0 ]]
then
echo "No EPs will be added to ${bname}"

else
##########################################################
# Count atoms and total particles (atoms + EPs)
###########################################################
n_or=`awk 'NR==3{print $1}' ${bname}.mol2`
nEP=`echo ${n_or}+${totX} | bc -lq`
###########################################################
# Add EPs to RESP
###########################################################
cp ${bname}.ESP ${bname}_${dEP}.ESP

for i in $(seq 1 1 $totX)
do
# Find halogen atoms and corresponding C's
a=$(bc <<< "$i-1")
n=`head -n3 ${bname}.mol2 | tail -1 | awk -v b=${a} '{print $1+b}'`
X=`grep ${Xtype}${i} ${bname}.mol2 | awk '{print $1}'`
C=`awk -v X=${X} '$0 ~ X  {if(NF==4 && $2==X) print $3; if(NF==4 && $3==X) print $2 }' ${bname}.mol2`

nep=`awk -v n=${n} 'BEGIN{print n+1}'`
Cndx=`awk -v C=${C} 'BEGIN{print C+1}'`
Xndx=`awk -v X=${X} 'BEGIN{print X+1}'`
#################
head -n 1 ${bname}_${dEP}.ESP | awk -v nep=$nep '{printf "%5i%5i%5i\n",nep,substr($0,6,5),substr($0,11,5)}' > TMP
##################
f=`awk -v dEP=${dEP} -v Cndx=${Cndx} -v Xndx=${Xndx} '{
if(NR==Cndx){XC=$1;YC=$2;ZC=$3};
if(NR==Xndx){XX=$1;YX=$2;ZX=$3}}
END{print 1.889725989*dEP/(sqrt((XX-XC)**2+(YX-YC)**2+(ZX-ZC)**2))}' ${bname}.ESP`
##################
awk -v f=${f} -v nep=${nep} -v Cndx=${Cndx} -v Xndx=${Xndx} 'NR>1{
print $0
if ( NR == Cndx ){XC=$1;YC=$2;ZC=$3}
if ( NR == Xndx ){XX=$1;YX=$2;ZX=$3}
if ( NR == nep  ){printf "                %16.7E%16.7E%16.7E\n", XX+f*(XX-XC),YX+f*(YX-YC),ZX+f*(ZX-ZC)}
}' ${bname}_${dEP}.ESP >> TMP
#################
mv TMP ${bname}_${dEP}.ESP
#################
done

##############################################################################
# Add EPs to RESP.in
##############################################################################

n=`echo $nEP-$totX | bc -l`
#############
#mv ${bname}_RESP1.IN AUX01
mv ${bname}_RESP1.IN AUX01
#############
head -n -1 AUX01 | head -n -${n} > AUX02
head -n -1 AUX02 > ${bname}_RESP1.IN
#############
tail -n 1 AUX02 | awk -v nEP=${nEP} '{printf "%5i%5i\n",$1,nEP}' >> ${bname}_RESP1.IN
#############
head -n -1 AUX01 | tail -n ${n} >> ${bname}_RESP1.IN
#############
for i in $(seq 1 1 $totX)
do
awk 'BEGIN{printf "%5i%5i\n",0,0}' >> ${bname}_RESP1.IN
done
#############
echo >> ${bname}_RESP1.IN
#############
/bin/rm -f AUX0{1,2}
#############

##############################################################################
# Run RESP for a defined distance
##############################################################################
${AMBERHOME}/bin/resp -O \
                      -i ${bname}_RESP1.IN \
                      -o ${bname}_RESP1_${dEP}.out \
                      -p ${bname}_RESP1_${dEP}.pch \
                      -t ${bname}_RESP1_${dEP}.chg \
                      -e ${bname}_${dEP}.ESP
/bin/rm esout


##############################################################################
# Add EPs to mol2 from RESP outputs
##############################################################################
mol2=${bname}.mol2
respout=${bname}_RESP1_${dEP}.out
n=`echo $nEP-$totX | bc -l`
#################################

# The total number of bonds is
nb_old=`awk 'NR==3{print $2}' ${mol2}`
nb_new=`awk -v totX=${totX} 'NR==3{print $2+totX}' ${mol2}`

# Extract atoms
cat ${mol2} | sed -n '/@<TRIPOS>ATOM/,/@<TRIPOS>BOND/p' | \
  head -n -1 | tail -n +2 | \
  awk '{print $1, $2, $3, $4, $5, $6, $7, $8}' > MOL.COORD

# The residue name is
resn=`head -2 ${mol2} | tail -1`
 
# Extract geometry of the EP from the outfile
for i in $(seq 1 1 ${totX})
do
halogen=`grep "${Xtype}${i} " ${mol2} | awk '{print $1}'`
a=$(bc <<< "${totX}-${i}+1")
cat ${respout} | sed -n '/ center     X       Y       Z/,/Initial ssvpot =/p' | \
                 head -n -1 | tail -${a} | head -1 | \
                 awk -v nEP=${nEP} -v resn=${resn} -v totX=${totX} -v i=${i} \
                   '{print nEP-(totX-i), "EP", $2*0.5292, $3*0.5292, $4*0.5292, "ep", "1", resn}' \
                   >> MOL.COORD
done

# Extract charges
cat ${respout} | \
  sed -n '/no.  At.no.    q(init)       q(opt)     ivary/,/Sum over the calculated charges:/p' | \
  head -n -2 | tail -n +2 | awk '{print $4}' > CHARGES

# Extract atoms
paste MOL.COORD CHARGES | \
  awk '{printf "%7.0f %3s %15.4f %9.4f %9.4f %2s %8.0f %3s %13.6f\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}' > COORD.MOL2

# Extract header and footer from mol2
sed -n "/@<TRIPOS>MOLECULE/,/${resn}/p" ${mol2} > HEADER1.MOL2
head -3 ${mol2} | tail -1 | \
  awk -v totX=${totX} '{printf "%5.0f %5.0f %5.0f %5.0f %5.0f\n", $1+totX, $2+totX, $3, $4, $5}' > HEADER2.MOL2
sed -n '/SMALL/,/@<TRIPOS>ATOM/p' ${mol2} > HEADER3.MOL2
sed -n '/@<TRIPOS>BOND/,/@<TRIPOS>SUBSTRUCTURE/p' ${mol2} | head -n -1 > FOOTER1.MOL2

for i in $(seq 1 1 ${totX})
do
halogen=`grep "${Xtype}${i} " ${mol2} | awk '{print $1}'`
awk -v halogen=${halogen} -v nEP=${nEP} -v nb_old=${nb_old} -v totX=${totX} -v i=${i} \
  'BEGIN {printf "%6.0f %5.0f %5.0f %1.0f\n", nb_old+i,halogen,nEP-(totX-i),"1"}' >> FOOTER2.MOL2
done

sed -n '/@<TRIPOS>SUBSTRUCTURE/,//p' ${mol2} > FOOTER3.MOL2

cat HEADER1.MOL2 HEADER2.MOL2 HEADER3.MOL2 COORD.MOL2 FOOTER1.MOL2 FOOTER2.MOL2 FOOTER3.MOL2 > ${bname}_${dEP}.mol2

rm -rf MOL.COORD EP*.COORD MOL.COORD.CORR CHARGES HEADER1.MOL2 HEADER2.MOL2 HEADER3.MOL2 COORD.MOL2 FOOTER1.MOL2 FOOTER2.MOL2 FOOTER3.MOL2 

fi

done

############################################################
# Generate topologies for all mol2 files
############################################################

for molfile in *.mol2
do
molname=`basename ${molfile} .mol2`

nep=`cat ${molname}.mol2 | awk '$6 == "ep"' | wc -l`

#####################
$AMBERHOME/bin/parmchk -i ${molname}.mol2 -f mol2 -o ${molname}.frcmod
#####################
resn=`awk 'NR==2' ${molname}.mol2`
#####################
cat << EOF > leap.in
source leaprc.gaff
mods = loadamberparams ${molname}.frcmod
${resn} = loadmol2 ${molname}.mol2
saveAmberParm ${resn} ${molname}.top ${molname}.crd
quit
EOF
#####################
$AMBERHOME/bin/tleap -f leap.in
#$AMBERHOME/bin/tleap -f leap.in > /dev/null 2>&1
/bin/rm leap.in leap.log
######################

acpype.py -p ${molname}.top -x ${molname}.crd 
mv MOL_GMX.gro ${molname}_GMX.gro
mv MOL_GMX.top ${molname}_GMX.top

cp ${molname}_GMX.top ${molname}_GMX.top.bak


###############################
# modifies topology files when EPs are present
###############################
if [[ $nep -eq 0 ]]
then
echo "No modifications will be performed on ${molname}_GMX.top"
else
echo "Adding virtual site(s) on ${molname}_GMX.top"

cp ${molname}_GMX.top ${molname}_GMX.top.bak

#####################################
# Remove bonds, angles, dihedrals for EPs
######################################
sed -i '/ - EP/d;/EP-/d;/-    EP/d;/EP -/d' ${molname}_GMX.top

#####################################
# Add virtual site for each halogen
#####################################

# identifies the halogens

for halogen in `sed -n '/bonds/,/pairs/p' ${molname}_GMX.top.bak | grep EP | awk '{print $1}'`
do
nC=`sed -n '/bonds/,/pairs/p' ${molname}_GMX.top | awk -v halogen=$halogen '{if ($1 == halogen) print $2; else if ($2 == halogen) print $1}'`
nEP=`sed -n '/bonds/,/pairs/p' ${molname}_GMX.top.bak | grep EP | awk -v halogen=$halogen '{if ($1 == halogen) print $2; else if ($2 == halogen) print $1}'`
Cdist=`sed -n '/bonds/,/pairs/p' ${molname}_GMX.top | awk -v halogen=$halogen '{if ($1 == halogen || $2 == halogen) print $4}'`
epdist=`awk -v Cdist=${Cdist} -v xep=${1} 'BEGIN {print -xep/(Cdist*10)}'`
 
# write virtual site block

#echo "[ virtual_sites2 ]" > VSITE.${molname}
echo ${nEP} ${halogen} ${nC} 1 ${epdist} >>  VSITE.${molname}
done 

sed -i '1 i\[ virtual_sites2 ]' VSITE.${molname}
sed -i '1 i\ ' VSITE.${molname}

sed -i "/qtot 0.000/r VSITE.${molname}" ${molname}_GMX.top
rm -rf VSITE.${molname}

fi

done
