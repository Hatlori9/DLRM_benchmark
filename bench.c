#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h> // Include for timing

#define MAX_LINE_LENGTH 4096

int main() {
    FILE *file = fopen("tensor_input.txt", "r");
    if (file == NULL) {
        perror("Unable to open file");
        return EXIT_FAILURE;
    }

    char line[MAX_LINE_LENGTH];
    int *indices = NULL, *offsets = NULL;
    int indicesCount = 0, offsetsCount = 0;
    int readingIndices = 0, readingOffsets = 0;
    long maxIndex = 0;

    while (fgets(line, MAX_LINE_LENGTH, file) != NULL) {
        if (strstr(line, "indices:") != NULL) {
            readingIndices = 1;
            readingOffsets = 0;
            continue;
        } else if (strstr(line, "offsets:") != NULL) {
            readingOffsets = 1;
            readingIndices = 0;
            continue;
        }

        if (readingIndices) {
            char *token = strtok(line, " .\n");
            while (token != NULL) {
                indices = realloc(indices, (indicesCount + 1) * sizeof(int));
                indices[indicesCount++] = atoi(token);
                if (indices[indicesCount - 1] > maxIndex) {
                    maxIndex = indices[indicesCount - 1];
                }
                token = strtok(NULL, " .\n");
            }
        } else if (readingOffsets) {
            char *token = strtok(line, " .\n");
            while (token != NULL) {
                offsets = realloc(offsets, (offsetsCount + 1) * sizeof(int));
                offsets[offsetsCount++] = atoi(token);
                token = strtok(NULL, " .\n");
            }
        }
    }
    fclose(file);

    int rowSize = 128; // Assume 64B row size for simplicity
    int numRows = (maxIndex + 1);
    int* embeddingTable = malloc(numRows * rowSize);
    if (embeddingTable == NULL) {
        perror("Failed to allocate memory for embedding table");
        return EXIT_FAILURE;
    }

    // Initialize embedding table with 1s for simplicity
    for (int i = 0; i < numRows * (rowSize / sizeof(int)); i++) {
        ((int*)embeddingTable)[i] = 1;
    }

    long long totalBytesTransferred = 0; // For bandwidth calculation
    for (int i = 0; i < offsetsCount - 1; i++) {
        int start = offsets[i];
        int end = offsets[i + 1];
        int sum = 0;
        for (int j = start; j < end; j++) {
            int index = indices[j];
            sum += ((int*)embeddingTable)[index];
            totalBytesTransferred += rowSize; // Add rowSize for each read
        }
        // Assuming sum is written back to memory (not shown here)
        printf("Sum for row %d to %d: %d\n", start, end - 1, sum);
    }

    long long totalMemoryUsed = (long long)numRows * rowSize + (long long)indicesCount * sizeof(int) + (long long)offsetsCount * sizeof(int);
    printf("Total Memory Used (Bytes): %lld\n", totalMemoryUsed);


    free(indices);
    free(offsets);
    free(embeddingTable);
    return EXIT_SUCCESS;
}
