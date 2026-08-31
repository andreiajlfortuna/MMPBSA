# MM-PBSA Simulations with Extra-Point (EP) for Halogen Anisotropy

This project contains the **machinery (scripts and files)** used to run **MM-PBSA simulations** incorporating an **extra-point (EP)** to describe halogen anisotropy. This method enables proper sampling of **halogen bonds** without disrupting **hydrogen bond** interactions. It played a crucial role in my **PhD thesis**, where I explored **noncovalent interactions** in solvation and membrane permeability. 

This approach was validated by comparing results with [gmx_MMPBSA](https://valdes-tresanco-ms.github.io/gmx_MMPBSA/dev/) for systems without EP. 

## Example System
The provided example (PDB: **1J91**) was studied in the work:
*Impact of the halogen PB radii in the estimation of protein-ligand binding energies using MM-PBSA calculations* (DOI: [10.1039/d5cp03537f](https://doi.org/10.1039/d5cp03537f)).

<img width="520" height="287" alt="image" src="https://github.com/user-attachments/assets/ee3ca4d2-3449-4a53-babd-17cdadaf0bf3" />


This study optimized **halogen PB radii** and several **EP models** to investigate halogen bonds in binding free energy calculations for **three sets of CK2-inhibitor complexes**.

---

## Project Structure
### 🔹 **Molecular Dynamics (MD) Folder**
The MD folder is organized into sequential steps:

- **📁 00_build** – Prepares the system for minimization.
- **📁 01_min** – Runs energy minimization.
- **📁 02_init_r1** – Initializes the simulation (**r1** = replicate 1; ideally, at least three replicates are needed).
- **📁 03_prod_r1** – Runs MD production.
- **📁 04_sysprep** – Extracts trajectories, generates visualizations, and converts **GROMACS** structures for **Amber** compatibility (including PB radii).
- **📁 05_MMPBSA_r1** – Extracts `.rst` files, corrects topologies, prepares input files, and executes **PBSA calculations** for each frame.

### 📊 **Analysis Folder**
This folder includes post-processing analysis:
- **📁 HBs_and_XBs** – **Hydrogen bonds** & **halogen bonds** analysis.
- **📁 correlations** – Statistical correlation analyses.

---


 

