import gzip
import torch
import numpy as np

#modify this line to get first N number of trace.
trace_range = 1000

# We use embedding table 856, can be others, 
# but do not merge any trace file, 
# since it will change the observed distribution of workload
gz_file_path = "fbgemm_t856_bs65536_0.pt.gz"

# Use gzip to open and read the file in binary mode, then load tensors
with gzip.open(gz_file_path, 'rb') as f:
    indices, offsets, lengths = torch.load(f)

# Only keep the first 'trace_range' elements of each tensor for simplification
indices_first_trace = indices[:trace_range]
offsets_first_trace = offsets[:trace_range]

# Convert the sliced tensors to NumPy arrays for easier handling
indices_np = indices_first_trace.numpy()
offsets_np = offsets_first_trace.numpy()

# Define the output file name
output_file = "tensor_input.txt"

# Write the details of the 'trace_range' elements to the output file
with open(output_file, "w") as out_f:
    # Temporarily adjust NumPy print settings to ensure full array printing without scientific notation
    with np.printoptions(threshold=np.inf, formatter={'all': lambda x: '{:.0f}'.format(x)}):
        out_f.write("indices:\n{}\n\n".format(indices_np))
        out_f.write("offsets:\n{}\n\n".format(offsets_np))

print(f"the {trace_range} elements written to {output_file}")
