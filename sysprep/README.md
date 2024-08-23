To prepare the system we consider the x-ray structure: 1j91.pdb

- first, we need to remove water molecules and the ligand: grep ATOM 1j91.pdb > 1j91_aligned.pdb

- then, align the optimized structure with the X-ray structure:
PyMOL>select lig, resn TBS
PyMOL>align TBS-opt-RESP_2.02_AMBER, lig

- fit of the optimized structure with the X-ray structure
PyMOL>wizard pair_fit 
PyMOL>set retain_order, 1
PyMOL>save TBS-opt-RESP_2.02_aligned_structureB.pdb, TBS-opt-RESP_2.02_AMBER, -1

merge the two structures:
cat 1j91_A_aligned.pdb TBS-opt-RESP_2.02_AMBER_aligned.pdb > 1j91_TBS_aligned_EP1.pdb
