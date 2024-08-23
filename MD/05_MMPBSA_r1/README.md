This folder has 8 individual scripts but you can make one if you prefer. I think that having a separate script for each crucial step enhances both overall organization and the ability to identify errors. Moreover, you have a lot of variables that you can change in this workflow and thus, it is important to understand in which steps you should make those decisions. The workflow is similar to the one employed in gmx_MMPBSA (https://valdes-tresanco-ms.github.io/gmx_MMPBSA/dev/), however, as mentioned previously, this program does not allow the use of an EP. I resolved this issue by using the pbsa module from amber. 

- **01_create_rst_files.sh**: for each frame from the trajectory (n_frames=1000, starting in 1) it creates an rst file using cpptraj.

- **02_create_folders.sh**: it creates folders using the logic: creates first a folder for each dielectric constant (epsilon) value (here I tested 3 values) and inside it creates a folder for each PB radii setup (here I tested three: pb1 - parse; pb2 - mbondi; pb3 - default of MMPBSA.py). 

I also tested the use of optimized radii (ropt) and standard (rstd) and so this script creates a separate folder for each within the corresponding PB radii setup. 

You must have the pb.in files with the right parameters for each PB radii setup (here I have the example for epsilon = 4, e.g.: pb1_4.in). 

- **03_correct_top.sh**: The radii that are assigned to halogens, by default, is "1.5000", therefore, we have to correct the topology files that were created in the previous step (04_sysprep) and assign the standard values or the optimized halogen PB radii (recommended, see paper: 10.1021/acs.jcim.1c00177).
