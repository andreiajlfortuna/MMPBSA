#! /bin/bash
usage="Usage: `basename $0` Name #CPUs\n
       Name : name of the input file (without extension)\n
       #CPUs: to be used in the calculation"

# Parse arguments
if [ $# != 2 ]; then
    echo -e $usage >/dev/stderr
    exit 1
fi
#
## Name for this Job (given as argument or added here)
## Please do not include file extension
Name=$1
#
## Number of Threads (processors given as argument or added here)
ncpus=$2
#
## Email Address to receive notification of completion:
## Multiple email addresses can be provided separated by comma.
## If left blank, no notification will be sent.
Email=""
#
## Working Dir:
Dir=`pwd`
#
## Please choose between G03 or G09
Gauss=g09
#
# Choose the list of machines (partition)
# More than one partition can be supplied, separated by commas and without spaces
# Choose this for jobs requiring:
# QMVHM:  very high memory (bio203-204)
# QMHM:   high memory (bio201-202,205-215)
# QMLM:   low to normal memory (bio216-221) (this should be chosen by DEFAULT)
Partition=QMLM
#
## Choose prefered file extensions
## .com/.log or .in/.out are just two examples
In=com
Out=log

#
## Here you can type your Job:
cat <<EOF >$Name.slurm
#! /bin/bash
#
. /etc/profile
. ~/.bashrc
. ~/.bash_profile
export EMAIL=$Email
InitDate=\`date\`
Gauss=$Gauss
if [ \$Gauss == "g03" ]; then
# G03 specific:
export g03root=/programs
. \$g03root/g03/bsd/g03.profile
export PATH=\$g03root/g03:\$PATH
fi
#
## If you need a g09 version different from default, please change and uncomment here:
# G09 specific:
#export g09root=/programs/g09-D01
#. \$g09root/g09/bsd/g09.profile
#export PATH=\$g09root/g09:\$PATH
#
mkdir /tmp/${USER}_${Gauss}_$$
#
if [ -f ${Name}.${In} -a -f ${Name}.chk ]; then cp -df ${Name}.{$In,chk} /tmp/${USER}_${Gauss}_$$
elif [ -f ${Name}.${In} -a ! -f ${Name}.chk ]; then cp -df ${Name}.${In} /tmp/${USER}_${Gauss}_$$
fi
#
cd /tmp/${USER}_${Gauss}_$$
#
# Give User some info on the Job location
echo -e "The job is running in: \$HOSTNAME" > $Dir/${Name}.info
echo -e "The job is located in: /tmp/${USER}_${Gauss}_$$" >> $Dir/${Name}.info
#
nice -n 19 ${Gauss} < ${Name}.${In} > ${Name}.${Out} 2> ${Name}.err
#
cp -df ${Name}.{chk,${Out},err} $Dir
if (for f in ${Name}.${Out} ${Name}.chk; do diff \${f} ${Dir}/\${f}; export file=\${f}; done); then
cd ${Dir}
/bin/rm -rf /tmp/${USER}_${Gauss}_$$
else
echo "Error in file \${file}" > ${Dir}/job_copy_error_$$.err
exit 1
fi
#
# Send email 
if [[ \$EMAIL != "" ]]; then
echo -e "Job $Name just finished on \$HOSTNAME with $ncpus CPU cores\n--Running since: \$InitDate \n--Finished on:   \`date\`" | mutt -s "BioISI Cluster Report: $Name" \$EMAIL
fi
#
EOF
#
chmod +x $Name.slurm
#
sbatch -p $Partition -N 1 -n $ncpus -o $Name.sout -e $Name.serr $Name.slurm
echo ""
echo "Job submitted to Partition(s): $Partition with $ncpus Processors"
#
## End of Script
#
