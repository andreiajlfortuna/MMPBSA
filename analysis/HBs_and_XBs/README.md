# Hydrogen Bond Analysis with MDAnalysis

This folder contains a script that analysis the hydrogen bonds established between the receptor-ligand pairs. To do this it uses the MDAnalysis (https://github.com/MDAnalysis, 10.25080/majora-629e541a-00e)


** HBs_MDAnalysis.py ** 

(e.g.: python HBs_MDAnalysis.py EP1)

- Placeholder Replacement: Replaces placeholders in a provided MDAnalysis script with specific donor and acceptor atom details.
- MD Analysis Execution: Automates the running of an MDAnalysis by calling external scripts.
- Hydrogen Bond Analysis: Processes hydrogen bond data to identify and record the shortest distances and associated angles between atoms across different frames.
- File Management: Organizes and renames output files to ensure results are stored correctly and are easily accessible.

* You will need to have:
  - A file with the name of your receptors and ligands (here: dGexp_setA);
  - The scripts run_MDanalysis_H and run_MDanalysis_O-N-S, which execute MDAnalysis for hydrogen bond acceptors and donors, respectively.
      - These scripts identify donors and acceptors and run MDAnalysis for all cases and replicates (3 replicates are considered in this script).
  - The MD trajectories (here: traj_10ns_r1.xtc)
  - The ligand itp file (here: TBS.itp)
  - The complex.prmtop file (modification required at line 171)
      - The script creates a symbolic link, but you need to modify the directory path.
      - The "EP1" value is used for the directory structure, so you will likely need to adjust this part as well.
 
