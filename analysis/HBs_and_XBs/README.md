
This folder contains a script that analysis the hydrogen bonds established between the receptor-ligand pairs. To do this it uses the MDAnalysis (https://github.com/MDAnalysis, 10.25080/majora-629e541a-00e)


** HBs_MDAnalysis.py ** 

(e.g.: python HBs_MDAnalysis.py EP1)

- Placeholder Replacement: Replaces placeholders in a provided MDAnalysis script with specific donor and acceptor atom details.
- MD Analysis Execution: Automates the running of an MDAnalysis by calling external scripts.
- Hydrogen Bond Analysis: Processes hydrogen bond data to identify and record the shortest distances and associated angles between atoms across different frames.
- File Management: Organizes and renames output files to ensure results are stored correctly and are easily accessible.

* You will need to have:
  - A file with the name of your receptors and ligands (here: dGexp_setA);
  - "run_MDanalysis_H" and "run_MDanalysis_O-N-S" which will run the MDAnalysis for the HB acceptor and donors respectively. This scrip will identify the presence of each donor and acceptor and run the MDAnalysis for all of the cases and for each replicate (this script consideres 3 replicates).
  - the MD trajectories (here: traj_10ns_r1.xtc)
  - the ligand itp file (here: TBS.itp)
  - the complex.prmtop file - change script in line: 171 (it creates a symbolic link but you have to change the directory. The "EP1" is needed for the directory part so you probability will need to change this part too)
 
