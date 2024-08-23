

# aling optimized structure with x-ray structure 
PyMOL>select lig, resn TBS
PyMOL>align TBS-opt-RESP_2.02_AMBER, lig
# fit of the optimized structure with the x-ray structure
PyMOL>wizard pair_fit 
PyMOL>set retain_order, 1
PyMOL>save TBS-opt-RESP_2.02_aligned_structureB.pdb, TBS-opt-RESP_2.02_AMBER, -1

 
#first remove waters and ligand
grep ATOM 1j91.pdb > 1j91_aligned.pdb

#save
pymol 1j91_A_aligned.pdb TBS-opt-RESP_2.02_AMBER_aligned.pdb (1j91_TBS_aligned_EP1.pdb)
