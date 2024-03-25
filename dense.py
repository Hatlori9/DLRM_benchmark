import torch
import torch.nn as nn
import sys

class BottomMLP(nn.Module):
    def __init__(self, input_dim, layer_sizes):
        super(BottomMLP, self).__init__()
        layers = []
        for output_dim in layer_sizes:
            layers.append(nn.Linear(input_dim, output_dim))
            layers.append(nn.ReLU())
            input_dim = output_dim
        self.network = nn.Sequential(*layers)

    def forward(self, x):
        return self.network(x)

class TopMLP(nn.Module):
    def __init__(self, input_dim, layer_sizes):
        super(TopMLP, self).__init__()
        layers = []
        for output_dim in layer_sizes:
            layers.append(nn.Linear(input_dim, output_dim))
            layers.append(nn.ReLU())
            input_dim = output_dim
        # Replace the last ReLU with a Sigmoid for binary classification output
        layers[-1] = nn.Sigmoid()
        self.network = nn.Sequential(*layers)

    def forward(self, x):
        return self.network(x)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <model_number> <number_of_queries>")
        sys.exit(1)

    model_number = int(sys.argv[1])
    num_queries = int(sys.argv[2])

    # Define the model configurations based on the input argument
    model_configs = {
        1: {'bottom': [256, 128, 128], 'top': [128, 64, 1]},
        2: {'bottom': [1024, 512, 128], 'top': [384, 192, 1]},
        3: {'bottom': [2048, 1024, 256], 'top': [512, 256, 1]},
        4: {'bottom': [2048, 2048, 256], 'top': [768, 384, 1]},
    }

    config = model_configs.get(model_number)
    if not config:
        print("Invalid model number. Please choose between 1 and 4.")
        sys.exit(1)

    bottom_mlp = BottomMLP(64, config['bottom'])  # Assuming embedding dimension is always 64 for bottom MLP
    top_mlp = TopMLP(config['top'][0], config['top'])  # First layer size is dynamically based on the input feature size

    # Example: Generate random data and run the models
    for _ in range(num_queries):
        # Generate a random feature vector for bottom MLP
        x_bottom = torch.rand(64)  # Random input vector for bottom MLP
        bottom_output = bottom_mlp(x_bottom)

        # Generate random interaction features for top MLP
        x_top = torch.rand(config['top'][0])  # Random input vector for top MLP
        top_output = top_mlp(x_top)

        print(f"Bottom MLP Output: {bottom_output}")
        print(f"Top MLP Output: {top_output}")
