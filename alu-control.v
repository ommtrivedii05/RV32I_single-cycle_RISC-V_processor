module alu_control (
    input  wire [1:0] alu_op,     // High-level ALUOp from controller
    input  wire [2:0] funct3,     // funct3 field from instruction
    input  wire [6:0] funct7,     // funct7 field from instruction
    output reg  [3:0] alu_ctrl    // Exact ALU control for alu.v
);

    //=================================================================
    // Combinational decode
    //=================================================================
    always @(*) begin

        // Default safe operation
        alu_ctrl = 4'b0000; // ADD

        case (alu_op)

            // ---------------------------------------------------------
            // ALUOp = 00 : Default ADD
            // Used by:
            //   - lw/sw address calculation
            //   - addi (also could be ALUOp=11, but ADD is same)
            //   - jalr base + offset
            //   - auipc (PC + imm)
            // ---------------------------------------------------------
            2'b00: begin
                alu_ctrl = 4'b0000; // ADD
            end

            // ---------------------------------------------------------
            // ALUOp = 01 : Branch operation
            // For BEQ/BNE, subtraction is typically used.
            // For BLT/BGE/BLTU/BGEU, branch_unit will compare directly.
            // ---------------------------------------------------------
            2'b01: begin
                alu_ctrl = 4'b0001; // SUB
            end

            // ---------------------------------------------------------
            // ALUOp = 10 : R-type (OP)
            // Decode using funct3 and funct7.
            // ---------------------------------------------------------
            2'b10: begin
                case (funct3)

                    3'b000: begin
                        // ADD/SUB depends on funct7[5]
                        // funct7 = 0000000 => ADD
                        // funct7 = 0100000 => SUB
                        if (funct7[5] == 1'b1)
                            alu_ctrl = 4'b0001; // SUB
                        else
                            alu_ctrl = 4'b0000; // ADD
                    end

                    3'b111: alu_ctrl = 4'b0010; // AND
                    3'b110: alu_ctrl = 4'b0011; // OR
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b010: alu_ctrl = 4'b0101; // SLT
                    3'b011: alu_ctrl = 4'b0110; // SLTU
                    3'b001: alu_ctrl = 4'b0111; // SLL

                    3'b101: begin
                        // SRL/SRA depends on funct7[5]
                        if (funct7[5] == 1'b1)
                            alu_ctrl = 4'b1001; // SRA
                        else
                            alu_ctrl = 4'b1000; // SRL
                    end

                    default: alu_ctrl = 4'b0000; // ADD safe fallback

                endcase
            end

            // ---------------------------------------------------------
            // ALUOp = 11 : I-type (OP-IMM)
            // Decode using funct3 and funct7 for shifts.
            // ---------------------------------------------------------
            2'b11: begin
                case (funct3)

                    3'b000: alu_ctrl = 4'b0000; // ADDI -> ADD
                    3'b111: alu_ctrl = 4'b0010; // ANDI -> AND
                    3'b110: alu_ctrl = 4'b0011; // ORI  -> OR
                    3'b100: alu_ctrl = 4'b0100; // XORI -> XOR
                    3'b010: alu_ctrl = 4'b0101; // SLTI -> SLT
                    3'b011: alu_ctrl = 4'b0110; // SLTIU -> SLTU
                    3'b001: alu_ctrl = 4'b0111; // SLLI -> SLL

                    3'b101: begin
                        // SRLI/SRAI depends on funct7[5]
                        if (funct7[5] == 1'b1)
                            alu_ctrl = 4'b1001; // SRAI -> SRA
                        else
                            alu_ctrl = 4'b1000; // SRLI -> SRL
                    end

                    default: alu_ctrl = 4'b0000; // ADD safe fallback

                endcase
            end

            default: begin
                alu_ctrl = 4'b0000; // ADD
            end

        endcase
    end

endmodule