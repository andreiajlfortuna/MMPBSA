#! /bin/bash

CPU=2
proc=10

# QMVHM:  very high memory (bio203-204)
# QMHM:   high memory (bio201-202,205-215)
# QMLM:   low to normal memory (bio216-221) 
Partition=QMLM,QMVHM,QMHM,MD32f,MD32c

for curr_proc in $(seq 1 1 $proc)

do

Name=mmpbsa_${curr_proc}

chmod +x $Name.slurm
#

sbatch -p $Partition -N 1 -n ${CPU} -o $Name.sout -e $Name.serr $Name.slurm
echo ""
echo "Job submitted to Partition(s): $Partition with ${CPU} Processors"

sleep 3

done
