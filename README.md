This project has the machinery (scripts and files) I used to run MM-PBSA simulations using an extra-point (EP) to describe the halogen anisotropy. This method allows the sampling of halogen bonds without impairing the sampling of hydrogen bonds and was extremely useful for my PhD thesis, where I studied the role of noncovalent interactions in solvation and membrane permeability. This approach was validated by comparing the results obtained with gmx_MMPBSA (https://valdes-tresanco-ms.github.io/gmx_MMPBSA/dev/) for systems without EP.  

The example given here (PDB:1J91) corresponds to one system studied in the work "Impact of the halogen PB radii in the estimation of protein-ligand binding energies using MM-PBSA calculations" (preprint available in: https://doi.org/10.26434/chemrxiv-2024-l32nf). In this study, optimized halogen PB radii and several EP to study halogen bonds in binding free energies for three sets of CK2-inhibitor complexes were used.

The MD folder is divided into the following steps (folders):

- **00_build**: Builds and prepares the system for minimization.
- **01_min**: Runs minimization.
- **02_init_r1**: Runs initialization (r1 corresponds to one replicate, ideally you should have at least three).
- **03_prod_r1**: Runs MD production.
- **04_sysprep**: Extract trajectories, create graphics, and transform the pdb (structure) from GROMACS to be compatible with amber to create proper topologies (with PB radii).
- **05_MMPBSA_r1**: Extracts .rst files from the MD trajectories, corrects topologies, prepares files, and runs PBSA calculations for each frame.

The analysis folder is divided into:
- **HBs_and_XBs**
- **correlations**
