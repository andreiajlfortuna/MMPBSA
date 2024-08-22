This project has the machinery (scripts and files) that I used to run MM-PBSA simulations. 
The example given here (PDB:1J91) corresponds to one system studied in the work "Impact of the halogen PB radii in the estimation of protein-ligand binding energies using MM-PBSA calculations" (preprint available in: https://doi.org/10.26434/chemrxiv-2024-l32nf)
The MD folder is divided into the following steps (folders):
00_build --> builds and prepares the system for minimization 
01_min --> runs minimization
02_init_r1 --> runs initialization (r1 corresponds to one replicate, ideally you should have at least three)
03_prod_r1 --> runs MD production
04_sysprep --> 
