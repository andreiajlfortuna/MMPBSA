#!/usr/bin/env python3

import pandas as pd
import MDAnalysis as mda
from MDAnalysis.analysis.hydrogenbonds import HydrogenBondAnalysis

FRAME = 0
DONOR = 1
HYDROGEN = 2
ACCEPTOR = 3
DISTANCE = 4
ANGLE = 5


master_df = pd.DataFrame()

u = mda.Universe("../complex.prmtop","../traj_10ns_rZZZ.xtc")
hbonds = HydrogenBondAnalysis(
    universe=u,
    acceptors_sel="protein and (name O or name N or name S)",
    donors_sel="name XXX",
    hydrogens_sel="name YYY",
    d_a_cutoff=3,
    d_h_a_angle_cutoff=150,
    update_selections=False
)
hbonds.run(
    start=None,
    stop=None,
    step=None,
    verbose=True
)

df = pd.DataFrame(hbonds.results.hbonds[:, :DISTANCE].astype(int),
                columns=["Frame",
                        "Donor_ix",
                        "Hydrogen_ix",
                        "Acceptor_ix",])

df["Distances"] = hbonds.results.hbonds[:, DISTANCE]
df["Angles"] = hbonds.results.hbonds[:, ANGLE]

df["Donor resname"] = u.atoms[df.Donor_ix].resnames
df["Acceptor resname"] = u.atoms[df.Acceptor_ix].resnames
df["Hydrogen resname"] = u.atoms[df.Hydrogen_ix].resnames

df["Donor resid"] = u.atoms[df.Donor_ix].resids
df["Acceptor resid"] = u.atoms[df.Acceptor_ix].resids
df["Hydrogen resid"] = u.atoms[df.Hydrogen_ix].resids

df["Donor name"] = u.atoms[df.Donor_ix].names
df["Acceptor name"] = u.atoms[df.Acceptor_ix].names
df["Hydrogen name"] = u.atoms[df.Hydrogen_ix].names

df.to_csv("hbonds.csv", index=False)


