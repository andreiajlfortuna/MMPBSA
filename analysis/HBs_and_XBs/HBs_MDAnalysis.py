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

# Function to replace placeholders in a file
def replace_in_file(file_path, replacements):
    with open(file_path, 'r') as file:
        content = file.read()
    
    for old_text, new_text in replacements.items():
        content = content.replace(old_text, new_text)
    
    with open(file_path, 'w') as file:
        file.write(content)

# Function to perform MD analysis
def run_md_analysis():
    os.system("./run_MDanalysis")

# Function to process results
def process_results(donor_or_acceptor, rep):
    results_file = f"hbonds_{donor_or_acceptor}_{rep}.csv"
    
    if os.path.exists("hbonds.csv"):
        shutil.move("hbonds.csv", results_file)
        print(f"Moved 'hbonds.csv' to '{results_file}'")
    else:
        print(f"Warning: 'hbonds.csv' not found for {donor_or_acceptor} {rep}. Skipping this result.")
        return

    output_file = f"HBshortestdist_{donor_or_acceptor}_{rep}.csv"
    try:
        with open(results_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
            reader = csv.reader(infile)
            writer = csv.writer(outfile)
            
            writer.writerow(["Frame", "AtomType", "Distance", "Angle"])
            next(reader, None)
            
            frame_data = []
            for row in reader:
                if len(row) >= 15:
                    try:
                        frame = int(row[0])
                        atom_type = f"{row[6]}_{row[14]}-{row[9]}"
                        distance = float(row[4])
                        angle = float(row[5])
                        frame_data.append((frame, atom_type, distance, angle))
                    except ValueError:
                        continue
            
            for frame in range(1001):
                filtered = [data for data in frame_data if data[0] == frame]
                if filtered:
                    sorted_by_distance = sorted(filtered, key=lambda x: x[2])[:3]
                    if sorted_by_distance:
                        sorted_by_angle = sorted(sorted_by_distance, key=lambda x: x[3])
                        shortest = sorted_by_angle[-1]
                        writer.writerow(shortest)
    except Exception as e:
        print(f"Error processing results: {e}")

# Parse arguments
if len(sys.argv) != 2:
    sys.stderr.write(usage)
    sys.exit(1)

method = sys.argv[1]

# Loop through receptor-ligand pairs
with open("../dGexp_setA", "r") as file:
    lines = file.readlines()[1:]
    for line in lines:
        rec = line.split()[0]

        with open("../dGexp_setA", "r") as file:
            for line in file:
                if line.startswith(rec):
                    lig = line.split()[1]
                    break

        os.chdir(f"{rec}_{lig}/")

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

        # Count hydrogen bond donors and acceptors
        nN = nO = nS = nH = 0
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
                        if columns[1] == "hn":
                            nH += 1

        # Process each type of donor
        def process_donor_atoms(donor_type, n_atoms):
            if n_atoms > 0:
                for i in range(1, n_atoms + 1):
                    donor = f"{donor_type}{i}"
                    for rep in range(1, 4):
                        shutil.copy(os.path.join("../../run_MDanalysis_O-N-S"), "run_MDanalysis")
                        replacements = {
                            "XXX": donor,
                            "ZZZ": str(rep)
                        }
                        replace_in_file("run_MDanalysis", replacements)
                        run_md_analysis()
                        process_results(donor, rep)
                        print(f" #################################### ")
                        print(f"{rec} {lig} {donor} (Donor) {rep} was done!")
                        print(f" #################################### ")

        # Function to extract the X value
        def extract_X_value(itp_file, acceptor):
            X = None
            in_bonds_section = False

            with open(itp_file, 'r') as itp:
                for line in itp:
                    # Start parsing after finding 'bonds' line
                    if 'bonds' in line:
                        in_bonds_section = True
                        continue

                    # Stop processing when the bonds section ends
                    if in_bonds_section and line.strip() == "":
                        break

                    # Process lines within the bonds section
                    if in_bonds_section:
                        columns = line.split()
                        if len(columns) >= 9:
                            # Check if the acceptor is in the 7th or 9th column
                            if columns[6] == acceptor:
                                X = columns[8]
                                break  # Break out of the loop once the correct X is found
                            elif columns[8] == acceptor:
                                X = columns[6]
                                break  # Break out of the loop once the correct X is found

            # If X is not found, return 'Unknown'
            if X is None:
                X = 'Unknown'

            return X

        def process_acceptor_atoms(nH):
            if nH > 0:
                for i in range(1, nH + 1):
                    acceptor = f"H{i}"
                    for rep in range(1, 4):
                        shutil.copy(os.path.join("../../run_MDanalysis_H"), "run_MDanalysis")
                
                        # Extract the X value using the function
                        X = extract_X_value(itp_file, acceptor)
                
                        replacements = {
                            "XXX": X,
                            "YYY": acceptor,
                            "ZZZ": str(rep)
                        }
                        replace_in_file("run_MDanalysis", replacements)
                        run_md_analysis()
                        process_results(acceptor, rep)
                        print(f" #################################### ")
                        print(f"{rec} {lig} {acceptor} (Acceptor) {rep} was done!")
                        print(f" #################################### ")

        # Process each type of donor and acceptor
        process_donor_atoms("N", nN)
        process_donor_atoms("O", nO)
        process_donor_atoms("S", nS)
        process_acceptor_atoms(nH)

        os.chdir("../..")  # Go back to the original directory level
