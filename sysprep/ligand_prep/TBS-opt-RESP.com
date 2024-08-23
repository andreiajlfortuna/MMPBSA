%mem=600MB
%nproc=4
%chk=TBS-opt-RESP
#hf/6-31G* scf(tight,maxcycles=1000) Pop=MK IOp(6/33=2,6/41=4,6/42=6) geom=check guess=read

TBS-op - RESP - HF/6-31G*  - radii bondi (vdw) as in gamess ;	4,5,6,7-tetrabromo-1H-benzotriazole

0 1





