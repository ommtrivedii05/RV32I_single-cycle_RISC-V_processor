module regfile (
    input  wire        clk,      // Clock input (positive-edge triggered)
    input  wire        rst_n,    // Active-low reset
    input  wire        we,       // Write enable
    input  wire [4:0]  rs1,      // Source register 1 index
    input  wire [4:0]  rs2,      // Source register 2 index
    input  wire [4:0]  rd,       // Destination register index
    input  wire [31:0] wd,       // Write data
    output wire [31:0] rd1,      // Read data from rs1
    output wire [31:0] rd2       // Read data from rs2
);

    //=============================================================
    // Register array: x0..x31
    //=============================================================
    reg [31:0] regs [0:31];

    integer i;

    //=============================================================
    // Synchronous write + reset logic
    //=============================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset: clear all registers
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'h0000_0000;
        end
        else begin
            // Normal write (ignore writes to x0)
            if (we && (rd != 5'd0))
                regs[rd] <= wd;

            // Force x0 = 0 always (extra safety)
            regs[0] <= 32'h0000_0000;
        end
    end

    //=============================================================
    // Combinational read ports
    //=============================================================
    assign rd1 = (rs1 == 5'd0) ? 32'h0000_0000 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'h0000_0000 : regs[rs2];

endmodule