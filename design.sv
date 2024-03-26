

`include "AccumulateConfigLogic.v"
module ProcessCore(
    input clk,
    input reset,
    input [63:0] instruction,
    output reg [63:0] mem_address,
    output reg mem_read_enable,
    output reg [63:0] data_to_accumulate,
    output reg accumulate_enable,
    output reg backpressure,
    output reg [63:0] to_on_switch_buffer,
    input [63:0] from_on_switch_buffer,
    output [63:0] accumulate_result,
    output reg write_enable_swap_reg,
    input [63:0] from_accumulate_logic
);

// Opcode definitions
localparam READ_MEMORY_OPCODE = 4'b0001;
localparam WRITE_SWAP_OPCODE = 4'b0010;
localparam ACCUMULATE_DATA_OPCODE = 4'b0011;
localparam READ_BUFFER_OPCODE = 4'b0100;
localparam WRITE_BUFFER_OPCODE = 4'b0101;

// Decode fields from instruction
reg [3:0] opcode;
reg [43:0] address_field;
reg [15:0] data_field;
reg buffer_ready_flag; // A flag to indicate buffer readiness
  
// Internal Registers
reg [63:0] swap_reg;
reg [63:0] instruction_ingress_registry;
reg [63:0] functional_config_register;
  
  
// Define 16 sets of Sum components
reg [31:0] SumAddress[0:15];
reg SumTag[0:15];
reg [31:0] SumCandidateCounter[0:15];
reg [63:0] SumValue[0:15];
reg [127:0] IngressBuffer [0:128];
  
  
integer i;
initial begin
    for (i = 0; i < 16; i = i + 1) begin
        SumAddress[i] = 32'h5000BF + i; // Example starting addresses
        SumTag[i] = 1'b1; // Initialize tags as '1'
        SumCandidateCounter[i] = 0; // Initialize counters
        SumValue[i] = 0; // Initialize values
    end
  for (i = 0; i < 128; i = i + 1) begin
        IngressBuffer[i] = 0; // Initialize values
    end
end


// Control signals
wire bp_from_accumulate_logic;

// Instantiate Accumulate Config Logic
AccumulateConfigLogic accumulateConfigLogic(
    .clk(clk),
    .reset(reset),
    .instruction(instruction),
    .data_in(from_accumulate_logic),
    .accumulate_result(accumulate_result),
    .bp_signal(bp_from_accumulate_logic)
);

  
  
  
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 16; i = i + 1) begin
            SumCandidateCounter[i] <= 0;
            SumValue[i] <= 0;
        end
        for (i = 0; i < 128; i = i + 1) begin
            IngressBuffer[i] <= 0;
        end
    end else begin
        if (accumulate_enable) begin
            SumValue[data_field[3:0]] <= SumValue[data_field[3:0]] + from_accumulate_logic;
            SumCandidateCounter[data_field[3:0]] <= SumCandidateCounter[data_field[3:0]] + 1;
        end
    end
end
  
  
  
// Process Core Logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset all outputs and flags
        mem_read_enable <= 0;
        mem_address <= 0;
        data_to_accumulate <= 0;
        accumulate_enable <= 0;
        backpressure <= 0;
        to_on_switch_buffer <= 0;
        write_enable_swap_reg <= 0;
        swap_reg <= 0;
        instruction_ingress_registry <= 0;
        functional_config_register <= 0;
        buffer_ready_flag <= 0;
    end else begin
        // Decode the instruction
        opcode <= instruction[63:60];
        address_field <= instruction[59:16];
        data_field <= instruction[15:0];
        
        // Handle different opcodes
        case (opcode)
            READ_MEMORY_OPCODE: begin
                mem_read_enable <= 1;
                mem_address <= {address_field, 20'b0}; // Assuming 44-bit address + 20-bit padding
            end
            WRITE_SWAP_OPCODE: begin
                write_enable_swap_reg <= 1;
                swap_reg <= from_accumulate_logic; // Directly writing data into swap register
            end
            ACCUMULATE_DATA_OPCODE: begin
                accumulate_enable <= 1;
                data_to_accumulate <= {48'b0, data_field}; // Assuming 16-bit data + 48-bit padding
            end
            READ_BUFFER_OPCODE: begin // Read from On-Switch Buffer Opcode
                if (buffer_ready_flag) begin
                    to_on_switch_buffer <= {address_field, 20'b0}; // Set buffer read address
                    mem_read_enable <= 0; // Disable memory read while reading from buffer
                end
            end
            WRITE_BUFFER_OPCODE: begin // Write to On-Switch Buffer Opcode
                // Trigger logic to write to On-Switch Buffer
                if (!buffer_ready_flag) begin
                    to_on_switch_buffer <= {48'b0, data_field}; // Set data to write to buffer
                end
            end
            default: begin
                // Reset all control signals for default case
                mem_read_enable <= 0;
                write_enable_swap_reg <= 0;
                accumulate_enable <= 0;
            end
        endcase
        
        // Handle backpressure from Accumulate Logic
        backpressure <= bp_from_accumulate_logic;
        
        // Logic for interacting with the On-Switch Buffer and Swap Register can be extended here
        // For example, handle the writing back to the On-Switch Buffer if a condition is met
        // Additional logic to set/reset the buffer_ready_flag based on system design
    end
end

endmodule
