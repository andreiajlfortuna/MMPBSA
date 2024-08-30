import os
import sys
import shutil
import csv

# Usage message
usage = """
Usage:
--------------------------------------------
METHOD (e.g. EP1, EP2, EP3, no_EP)
"""

# Use the current directory for the run_MDanalysis_O-N-S script
current_dir = os.getcwd() 

# Function to replace placeholders in a file
def replace_in_file(file_path, replacements):
    """
    Replaces placeholders in the file with given replacements.

    Parameters:
    - file_path: Path to the file where replacements will be made.
    - replacements: Dictionary where keys are placeholders and values are the new text.
    """
    with open(file_path, 'r') as file:
        content = file.read()
    
    for old_text, new_text in replacements.items():
        content = content.replace(old_text, new_text)
    
    with open(file_path, 'w') as file:
        file.write(content)

# Function to perform MD analysis
def run_md_analysis():
    os.system("./run_MDanalysis")

def process_results(donor, rep):
    results_file = f"hbonds_{donor}_{rep}.csv"
    shutil.move("hbonds.csv", results_file)

    # Process the results
    with open(results_file, 'r') as infile, open(f"HBshortestdist_{donor}_{rep}.csv", 'w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        writer.writerow(["Frame", "AtomType", "Distance", "Angle"])

        # Skip the header
        next(reader)

        # Parse and process the results
        frame_data = []
        for row in reader:
            if len(row) >= 7:
                try:
                    frame = int(row[0])
                    atom_type = f"{row[6]}_{row[14]}-{row[9]}"
                    distance = row[4]
                    angle = row[5]
                    frame_data.append((frame, atom_type, distance, angle))
                except ValueError:
                    continue
        
        # Sort and select the shortest distances
        for frame in range(1001):
            filtered = [data for data in frame_data if data[0] == frame]
            if filtered:
                sorted_by_distance = sorted(filtered, key=lambda x: float(x[2]))[:3]
                if sorted_by_distance:
                    sorted_by_angle = sorted(sorted_by_distance, key=lambda x: float(x[3]))
                    shortest = sorted_by_angle[-1]
                    writer.writerow(shortest)

    print(f" #################################### ")
    print(f"{rec} {lig} {donor} {rep} was done!")
    print(f" #################################### ")

# Parse arguments
if len(sys.argv) != 2:
    sys.stderr.write(usage)
    sys.exit(1)

method = sys.argv[1]
 

# Loop through receptor-ligand pairs
with open("../dGexp_setA", "r") as file:
    lines = file.readlines()[1:]  # Skip the first line
    for line in lines:
        rec = line.split()[0]

        # Get ligand using Python
        with open("../dGexp_setA", "r") as file:
            for line in file:
                if line.startswith(rec):
                    lig = line.split()[1]
                    break

        os.chdir(f"{rec}_{lig}/")

        # File management
        if os.path.exists("complex_parse.prmtop"):
            os.remove("complex_parse.prmtop")
        os.symlink(f"/home/afortuna/mm-pbsa-ck2/systems_build/set_A/{rec}_{lig}_{method}/MD/05_MMPBSA_r1/epsin_1/pb2/rstd/complex.prmtop", "complex_parse.prmtop")

        # Hydrogen bond analysis
        hb_dir = "count_HBs/"
        if os.path.exists(hb_dir):
            shutil.rmtree(hb_dir)
        os.mkdir(hb_dir)
        os.chdir(hb_dir)

        if os.path.exists("MIN_SUMMARY"):
            os.remove("MIN_SUMMARY")

        itp_file = f"../{lig}.itp"

        # Count hydrogen bond acceptors
        nN = nO = nS = 0
        with open(itp_file, "r") as itp:
            atoms_section = False
            for line in itp:
                if 'atoms' in line:
                    atoms_section = True
                    continue
                if atoms_section and line.strip() == "":
                    break
                if atoms_section:
                    columns = line.split()
                    if len(columns) >= 6:
                        atom_type = columns[4]
                        if "N" in atom_type:
                            nN += 1
                        if "O" in atom_type:
                            nO += 1
                        if "S" in atom_type:
                            nS += 1

        # Process each type of donor
        def process_donor_atoms(donor_type, n_atoms):
            if n_atoms > 0:
                for i in range(1, n_atoms + 1):
                    donor = f"{donor_type}{i}"
                    for rep in range(1, 4):
                        
                        # Copy and prepare the run_MDanalysis script from the current directory
                        shutil.copy(os.path.join(current_dir, "run_MDanalysis_O-N-S"), "run_MDanalysis")
 

                        # Prepare replacements for placeholders
                        replacements = {
                            "XXX": donor,
                            "ZZZ": str(rep)
                        }

                        # Perform the replacements
                        replace_in_file("run_MDanalysis", replacements)

                        # Execute the MD analysis
                        run_md_analysis()

                        # Process the results
                        process_results(donor, rep)

        process_donor_atoms("N", nN)
        process_donor_atoms("O", nO)
        process_donor_atoms("S", nS)

        os.chdir("../..")  # Go back to the original directory level
