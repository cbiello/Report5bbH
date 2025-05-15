#!/bin/bash                                                                                                                                                                                                                

# Input file
input="geneva_yHiggs.py"

# Output files
cen_out="geneva_CEN.top"
min_out="geneva_MIN.top"
max_out="geneva_MAX.top"

# First line to add to all output files
header_line="# y_Higgs index      4"

# Use Python to extract and write the .top files
python3 <<EOF
import numpy as np

# Read the file
with open("$input") as f:
    content = f.read()

# Evaluate the arrays from the file
globals_dict = {}
exec(content, globals_dict)

binlow = np.array(globals_dict['binlow'])
binhigh = np.array(globals_dict['binhigh'])
value = np.array(globals_dict['value'])
low_envelope = np.array(globals_dict['low_envelope'])
high_envelope = np.array(globals_dict['high_envelope'])
error = np.array(globals_dict['error'])

# Sanity check
assert len(binlow) == len(binhigh) == len(value) == len(low_envelope) == len(high_envelope) == len(error), "Length mismatch"

# Fortran-style formatting function
def fortran_sci(val):
    return f"{val:.6e}".replace("e", "D").replace("E", "D")

# Header line
header = "$header_line"

# Helper to write .top files
def write_top(filename, central_values):
    with open(filename, 'w') as f:
        f.write(header + "\\n")
        for i in range(len(binlow)):
            f.write(f"{fortran_sci(binlow[i])} {fortran_sci(binhigh[i])} {fortran_sci(central_values[i])} {fortran_sci(error[i])}\\n")

# Write files
write_top("$cen_out", value)
write_top("$min_out", low_envelope)
write_top("$max_out", high_envelope)
EOF

echo "Done: geneva_CEN.top, geneva_MIN.top, geneva_MAX.top created."
