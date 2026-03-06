module branch_unit (
    input  wire [2:0]  funct3,        // Branch funct3
    input  wire [31:0] rs1_val,        // rs1 register value
    input  wire [31:0] rs2_val,        // rs2 register value
    output reg         take_branch     // Branch decision output
);

    //=================================================================
    // Internal comparison signals
    //=================================================================
    wire eq;
    wire lt_signed;
    wire lt_unsigned;

    assign eq          = (rs1_val == rs2_val);
    assign lt_signed   = ($signed(rs1_val) < $signed(rs2_val));
    assign lt_unsigned = (rs1_val < rs2_val);

    //=================================================================
    // Branch decision logic (combinational)
    //=================================================================
    always @(*) begin
        take_branch = 1'b0;

        case (funct3)

            3'b000: begin
                // BEQ
                take_branch = eq;
            end

            3'b001: begin
                // BNE
                take_branch = ~eq;
            end

            3'b100: begin
                // BLT (signed)
                take_branch = lt_signed;
            end

            3'b101: begin
                // BGE (signed) => !(rs1 < rs2)
                take_branch = ~lt_signed;
            end

            3'b110: begin
                // BLTU (unsigned)
                take_branch = lt_unsigned;
            end

            3'b111: begin
                // BGEU (unsigned) => !(rs1 < rs2)
                take_branch = ~lt_unsigned;
            end

            default: begin
                // Not a valid branch funct3
                take_branch = 1'b0;
            end

        endcase
    end

endmodule