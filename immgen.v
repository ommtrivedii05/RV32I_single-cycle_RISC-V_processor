module imm_gen (
    input  wire [31:0] instr,     // Full 32-bit instruction

    output wire [31:0] imm_i,      // I-type immediate
    output wire [31:0] imm_s,      // S-type immediate
    output wire [31:0] imm_b,      // B-type immediate
    output wire [31:0] imm_u,      // U-type immediate
    output wire [31:0] imm_j       // J-type immediate
);

    //=================================================================
    // I-type Immediate (12-bit signed)
    // Format:
    //   imm[11:0] = instr[31:20]
    //
    // Used by:
    //   - addi, andi, ori, xori, slti, sltiu
    //   - slli, srli, srai  (shamt in imm[4:0])
    //   - lw
    //   - jalr
    //=================================================================
    assign imm_i = {{20{instr[31]}}, instr[31:20]};

    //=================================================================
    // S-type Immediate (12-bit signed)
    // Format:
    //   imm[11:5] = instr[31:25]
    //   imm[4:0]  = instr[11:7]
    //
    // Used by:
    //   - sw
    //=================================================================
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

    //=================================================================
    // B-type Immediate (13-bit signed, branch offsets)
    // Format (NOTE bit0 = 0):
    //   imm[12]   = instr[31]
    //   imm[11]   = instr[7]
    //   imm[10:5] = instr[30:25]
    //   imm[4:1]  = instr[11:8]
    //   imm[0]    = 0
    //
    // Used by:
    //   - beq, bne, blt, bge, bltu, bgeu
    //
    // IMPORTANT:
    //   - The produced imm_b is already shifted left by 1.
    //=================================================================
    assign imm_b = {
        {19{instr[31]}},   // sign extension
        instr[31],         // imm[12]
        instr[7],          // imm[11]
        instr[30:25],      // imm[10:5]
        instr[11:8],       // imm[4:1]
        1'b0               // imm[0]
    };

    //=================================================================
    // U-type Immediate (upper 20 bits)
    // Format:
    //   imm[31:12] = instr[31:12]
    //   imm[11:0]  = 0
    //
    // Used by:
    //   - lui
    //   - auipc
    //=================================================================
    assign imm_u = {instr[31:12], 12'b0};

    //=================================================================
    // J-type Immediate (21-bit signed, jump offsets)
    // Format (NOTE bit0 = 0):
    //   imm[20]   = instr[31]
    //   imm[19:12]= instr[19:12]
    //   imm[11]   = instr[20]
    //   imm[10:1] = instr[30:21]
    //   imm[0]    = 0
    //
    // Used by:
    //   - jal
    //
    // IMPORTANT:
    //   - The produced imm_j is already shifted left by 1.
    //=================================================================
    assign imm_j = {
        {11{instr[31]}},   // sign extension
        instr[31],         // imm[20]
        instr[19:12],      // imm[19:12]
        instr[20],         // imm[11]
        instr[30:21],      // imm[10:1]
        1'b0               // imm[0]
    };

endmodule