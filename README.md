# DLRM_benchmark

## How to run:
1. First, have the `pt.gz` trace file downloaded.

2. Modify the file path in `pt_to_gz.py` to generate the trace file. A sample trace file has been generated for testing (first 1000 processes).

3. Compile the benchmark program: gcc bench.c -o bench

4. Execute the benchmark: ./bench



**Note**: Currently, the malloc space is allocated according to the max index of indices * row size (64B/128B). Please increase the `trace_range` in `pt_to_gz.py` until it hits the memory budget (whenever it prints "segmentation fault").

### A embedding table operation sample

Let's use a simplified example to illustrate:

- **Indices**: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
- **Offsets**: [0, 3, 5, 10]

This means:
- The first sequence of indices for processing includes `[1, 2, 3]` (from position 0 to position 2).
- The second sequence includes `[4, 5]` (from position 3 to position 4).
- The third and last sequence includes `[6, 7, 8, 9, 10]` (from position 5 to the end of the array).
