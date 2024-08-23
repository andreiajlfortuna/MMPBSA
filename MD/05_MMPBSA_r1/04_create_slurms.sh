#! /bin/bash

#nr of processes
proc=10
frames=1000


for curr_proc in $(seq 1 1 $proc)

do

delta=`echo "$frames/$proc" | bc`

if [[ ${curr_proc} == 1 ]]
then
init_frame=1
end_frame=100
else
end_frame=$((end_frame+delta))
init_frame=$((init_frame+delta))
fi

Name=mmpbsa_${curr_proc}

Dir=`pwd`



## Here you can type your Job:
cat <<EOF >$Name.slurm
#! /bin/bash
#
. /etc/profile
. ~/.bashrc
. ~/.bash_profile
InitDate=\`date\`

# Give User some info on the Job location
echo -e "The job is running in: \$HOSTNAME" > $Dir/${Name}.info
#

source /home/pjcosta/bin/amber/amber20-with-ep-new/amber.sh
AMBERHOME=/home/pjcosta/bin/amber/amber20-with-ep-new

for i in 2

do

cd epsin_\${i}/ 

for setup in pb2 pb3

do

cd \${setup}/

for radii in rstd ropt

do

cd \${radii}/

for a in complex receptor ligand
do

for i in \$(seq $init_frame 1 $end_frame)

do

\$AMBERHOME/bin/pbsa -O -i ../pb.in -o \${a}_\${i}.out -p \${a}.prmtop -c ../../../rstfiles/\${a}_\${i}.rst 


done
done

cd ../
done
cd ../
done
cd ../
done
EOF

sleep 1
#

done



