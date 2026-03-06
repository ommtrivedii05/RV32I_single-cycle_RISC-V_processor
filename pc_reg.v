module pc_reg (
    input  wire        clk,        // Clock input (positive-edge triggered)
    input  wire        rst_n,      // Active-low synchronous reset
    input  wire [31:0] pc_next,    // Next PC value computed by pc_next_logic
    output reg  [31:0] pc_current  // Current PC value used for instruction fetch
);

    //=================================================================
    // Sequential Logic: Program Counter Update
    //=================================================================
    // Triggering:
    //   - Updates on rising edge of clk
    //   - Resets on rising edge of clk when rst_n is low
    //
    // Reset Behavior:
    //   - PC is reset to 0x00000000
    //
    // Normal Operation:
    //   - PC loads pc_next every cycle
    //=================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            pc_current <= 32'h0000_0000;   // Reset PC to address 0
        end
        else begin
            pc_current <= pc_next;         // Update PC with computed next value
        end
    end

endmodule