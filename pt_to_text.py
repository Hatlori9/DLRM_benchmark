import gzip
import torch
import numpy as np
 
# Modify this line to get the first N number of trace. 
trace_range = 1000
# Maximum value for trace elements.
max_trace_value = 1000000
 
# We use embedding table 856, can be others, 
# but do not merge any trace file, 
# since it will change the observed distribution of workload.
gz_file_path = "fbgemm_t856_bs65536_0.pt.gz"
 
# Use gzip to open and read the file in binary mode, then load tensors.
with gzip.open(gz_file_path, 'rb') as f:
    indices, offsets, lengths = torch.load(f)
 
# Only keep the first 'trace_range' elements of each tensor for simplification.
indices_first_trace = indices[:trace_range]
offsets_first_trace = offsets[:trace_range]
 
# Filter out indices larger than 'max_trace_value' and their corresponding offsets.
valid_indices_mask = indices_first_trace < max_trace_value
filtered_indices = indices_first_trace[valid_indices_mask]
filtered_offsets = offsets_first_trace[valid_indices_mask]
 
# Convert the filtered tensors to NumPy arrays for easier handling.
indices_np = filtered_indices.numpy()
offsets_np = filtered_offsets.numpy()
 
# Define the output file name.
output_file = "tensor_input_filtered.txt"
 
# Write the details of the filtered elements to the output file.
with open(output_file, "w") as out_f:
    # Temporarily adjust NumPy print settings to ensure full array printing without scientific notation.
    with np.printoptions(threshold=np.inf, formatter={'all': lambda x: '{:.0f}'.format(x)}):
        out_f.write("indices:\n{}\n\n".format(indices_np))
        out_f.write("offsets:\n{}\n\n".format(offsets_np))
 
print(f"The filtered elements written to {output_file}")
