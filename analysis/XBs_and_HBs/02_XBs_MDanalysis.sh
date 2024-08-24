#!/bin/bash 

usage="Usage: 
      --------------------------------------------\n
       
       METHOD (e.g. EP1, EP2, EP3, no_EP)"

# Parse arguments
if [ $# != 1 ]; then
    echo -e $usage >/dev/stderr
    exit 1
fi

method=$1

dir=/home/afortuna/mm-pbsa-ck2/systems_build/set_A/XBs_HBs_count/scripts_count_XBs

for rec in $(tail -n +2 ../dGexp_setA | awk '{print $1}')

do

lig=$(awk -v rec=${rec} '($1~rec){print $2}' ../dGexp_setA)

cd ${rec}_${lig}/


################################################################
############# run mdanalysis for halogen bonds #################
################################################################

###### 1st find what halogen type and how many per compound ######

rm -rf count_XBs
mkdir count_XBs
cd count_XBs/

itp=../${lig}.itp

ncl=`sed -n -r '/atoms/,/^\s*$/p' ${itp} | awk '$2 == "cl"' | wc -l`
nbr=`sed -n -r '/atoms/,/^\s*$/p' ${itp} | awk '$2 == "br"' | wc -l`
ni=`sed -n -r '/atoms/,/^\s*$/p' ${itp} | awk '$2 == "i"'  | wc -l`

############### If Cl exist #############

if [ ${ncl} -gt 0 ]
then

Xtype=CL

for i in $(seq 1 1 ${ncl})

do

cp ${dir}/mdanalysis_O-N-S_template.dat mdanalysis.dat 


X=${Xtype}${i}

C=$(sed -n -r '/bonds/,/^\s*$/p' ${itp} | awk -v X=${X} '{if($7 == X){print $9} else if($9 == X){print $7}}')

sed -i "s/XXX/${X}/g" mdanalysis.dat

sed -i "s/CCC/${C}/g" mdanalysis.dat

${dir}/mdanalysisv10.py @mdanalysis.dat

done
fi

########### if BR exist ############

if [ ${nbr} -gt 0 ]
then

Xtype=BR

for i in $(seq 1 1 ${nbr})

do

cp ${dir}/mdanalysis_O-N-S_template.dat mdanalysis.dat 

 

X=${Xtype}${i}

C=$(sed -n -r '/bonds/,/^\s*$/p' ${itp} | awk -v X=${X} '{if($7 == X){print $9} else if($9 == X){print $7}}')

sed -i "s/XXX/${X}/g" mdanalysis.dat

sed -i "s/CCC/${C}/g" mdanalysis.dat

${dir}/mdanalysisv10.py @mdanalysis.dat

done
fi

########### If I exist ################


if [ ${ni} -gt 0 ]
then

Xtype=I

for i in $(seq 1 1 ${ni})

do

cp ${dir}/mdanalysis_template.dat mdanalysis.dat 

cp ${dir}/mdanalysis_O-N-S_template.dat mdanalysis.dat 

X=${Xtype}${i}

C=$(sed -n -r '/bonds/,/^\s*$/p' ${itp} | awk -v X=${X} '{if($7 == X){print $9} else if($9 == X){print $7}}')

sed -i "s/XXX/${X}/g" mdanalysis.dat

sed -i "s/CCC/${C}/g" mdanalysis.dat

${dir}/mdanalysisv10.py @mdanalysis.dat

done
fi

cd ../../
done

echo "DONE"
