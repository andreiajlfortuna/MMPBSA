%mem=900MB
%nproc=4
%chk=TBS-opt
#b3lyp/6-311G** opt freq scf(tight,maxcycles=1000)

TBS-opt - DFT (B3LYP/6-311G**) ; 	4,5,6,7-tetrabromo-1H-benzotriazole

0 1
C        0.277252750      0.224384835     -2.802104380
C        0.277252750     -0.437235172     -1.561313790
C        0.277252750      0.343081784     -0.370571701
C        0.277252750      1.741875740     -0.391935292
C        0.277252750      2.364112202     -1.634513778
C        0.277252750      1.612612294     -2.827880905
N        0.277252750     -1.816070829     -1.156129466
N        0.277252750     -1.833939752      0.213099167
N        0.277252750     -0.536726134      0.693132097
Br       0.277252750      2.773864675      1.250805965
Br       0.277252750      4.301796192     -1.729280615
Br       0.277252750      2.534375636     -4.534911175
Br       0.277252750     -0.789206201     -4.456260725
H        0.277252750     -0.277078571      1.658835542



