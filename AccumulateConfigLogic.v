// Assume this module is in a file named AccumulateConfigLogic.v
module AccumulateConfigLogic(
    input clk,
    input reset,
    input [63:0] instruction,
    input [63:0] data_in,
    output reg [63:0] accumulate_result,
    output reg bp_signal // Backpressure signal
);

    reg [31:0] capacity_counter;
    reg [31:0] sum_candidate_counter;
    reg [63:0] accumulate_config_register;
    reg accumulate_enabled; // Flag to enable accumulation

    wire [3:0] opcode = instruction[63:60];
    localparam CONFIG_OPCODE = 4'h1; // Opcode for configuration
    localparam ACCUMULATE_OPCODE = 4'h2; // Opcode for accumulation
    localparam DISABLE_ACCUMULATION_OPCODE = 4'h3; // New: Disable accumulation

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            capacity_counter <= 10; // Example initial capacity
            sum_candidate_counter <= 5; // Initial sum candidate count
            accumulate_config_register <= 0;
            accumulate_result <= 0;
            bp_signal <= 0;
            accumulate_enabled <= 0;
        end else begin
            case (opcode)
                CONFIG_OPCODE: begin
                    // Configuring capacity and sum candidate counter
                    capacity_counter <= instruction[31:0];
                    sum_candidate_counter <= instruction[59:32];
                    accumulate_config_register <= instruction;
                    accumulate_enabled <= 1; // Enable accumulation by default after configuration
                    bp_signal <= 0;
                end
                ACCUMULATE_OPCODE: begin
                    if (accumulate_enabled && capacity_counter > 0 && sum_candidate_counter > 0) begin
                        accumulate_result <= accumulate_result + data_in;
                        sum_candidate_counter <= sum_candidate_counter - 1;
                        capacity_counter <= capacity_counter - 1;
                        bp_signal <= 0;
                    end else begin
                        bp_signal <= 1; // Signal backpressure if at capacity or disabled
                    end
                end
                DISABLE_ACCUMULATION_OPCODE: begin
                    // New logic to disable accumulation dynamically
                    accumulate_enabled <= 0;
                end
            endcase
        end
    end
endmodule
