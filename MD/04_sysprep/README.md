
**04_extract_traj.sh**:

- concatenate the traj (trjcat, GROMACS)
- Create the xtc file with the trajectories (trjconv, GROMACS)

**05_graphics.sh**: 

this script creates several graphics that have the RMSD values over time, of the full protein, protein CAs or ligand and using as reference the first MD frame or the X-ray structure (created using rms, GROMACS).
gnuplot rmsdgraphic_r${rep}.plot --> the plot file is necessary to create the graphics. rep correspond to the number o replicates. In this example only rep1 is provided.

 **06_make_top.sh**:

transforms the topology from GROMACS to be compatible with amber (tleap). This is a similar workflow than the one employed by gmx_MMPBSA.py; however, this program doesn't allow the use of EPs.
this script does several steps:

- make index (make_ndx, GROMACS)
- make pdb of the complex (trjconv, GROMACS)
- remove hydrogens (pdb4amber, amber)
- replace OC1 and OC2 for O and OXT
- replace CD for CD1 when residue=ILE
- correct last residue atomic number
- correct HIS residues
- create topologies (tleap, amber)
