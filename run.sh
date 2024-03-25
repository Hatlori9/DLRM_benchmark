#!/bin/bash

# Run bench in the background and get its process ID
./bench &
BENCH_PID=$!

# Run dense.py in the background and get its process ID
python dense.py &
DENSE_PID=$!

# Wait for either process to complete
while kill -0 $BENCH_PID 2> /dev/null && kill -0 $DENSE_PID 2> /dev/null; do
    sleep 1
done

# Once we reach here, at least one process has finished.
# Kill both processes to ensure they both stop.
kill $BENCH_PID 2> /dev/null
kill $DENSE_PID 2> /dev/null

echo "Either bench or dense.py has completed. Both processes have been stopped."
