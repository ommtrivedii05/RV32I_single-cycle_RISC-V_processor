module decoder_controller (
    input  wire [6:0] opcode,        // instr[6:0]
    input  wire [2:0] funct3,        // instr[14:12]
    input  wire [6:0] funct7,        // instr[31:25]

    // -------------------------
    // Writeback controls
    // -------------------------
    output reg        reg_write,      // regfile write enable
    output reg [2:0]  wb_sel,         // writeback mux select

    // -------------------------
    // Execute controls
    // -------------------------
    output reg        alu_src,         // 0: rs2, 1: imm
    output reg [1:0]  alu_op,          // goes to alu_control
    output reg        use_pc_as_alu_a,  // 1: ALU A = PC, 0: ALU A = rs1

    // -------------------------
    // Memory controls
    // -------------------------
    output reg        mem_read,        // data memory read enable
    output reg        mem_write,       // data memory write enable

    // -------------------------
    // Control-flow controls
    // -------------------------
    output reg        branch,          // branch instruction
    output reg        jump,            // jal instruction
    output reg        jalr             // jalr instruction
);

    //=================================================================
    // Opcode Definitions (RV32I)
    //=================================================================
    localparam [6:0] OPCODE_OP       = 7'b0110011; // R-type
    localparam [6:0] OPCODE_OP_IMM   = 7'b0010011; // I-type ALU
    localparam [6:0] OPCODE_LOAD     = 7'b0000011; // lw
    localparam [6:0] OPCODE_STORE    = 7'b0100011; // sw
    localparam [6:0] OPCODE_BRANCH   = 7'b1100011; // beq/bne/...
    localparam [6:0] OPCODE_JAL      = 7'b1101111; // jal
    localparam [6:0] OPCODE_JALR     = 7'b1100111; // jalr
    localparam [6:0] OPCODE_LUI      = 7'b0110111; // lui
    localparam [6:0] OPCODE_AUIPC    = 7'b0010111; // auipc

    //=================================================================
    // WB Mux Encoding (wb_sel)
    //=================================================================
    // 000 : ALU result
    // 001 : Memory read data (lw)
    // 010 : PC + 4 (jal, jalr)
    // 011 : U-immediate (lui)
    // 100 : PC + imm (auipc)
    //=================================================================

    //=================================================================
    // Main Decode Logic
    //=================================================================
    always @(*) begin

        // ------------------------------------------------------------
        // Default safe values (NOP-like behavior)
        // ------------------------------------------------------------
        reg_write       = 1'b0;
        wb_sel          = 3'b000;

        alu_src         = 1'b0;
        alu_op          = 2'b00;
        use_pc_as_alu_a = 1'b0;

        mem_read        = 1'b0;
        mem_write       = 1'b0;

        branch          = 1'b0;
        jump            = 1'b0;
        jalr            = 1'b0;

        // ------------------------------------------------------------
        // Decode based on opcode
        // ------------------------------------------------------------
        case (opcode)

            //=========================================================
            // R-type (OP)
            //=========================================================
            OPCODE_OP: begin
                reg_write       = 1'b1;
                wb_sel          = 3'b000; // ALU result

                alu_src         = 1'b0;   // rs2
                alu_op          = 2'b10;  // R-type decode
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b0;
                mem_write       = 1'b0;

                branch          = 1'b0;
                jump            = 1'b0;
                jalr            = 1'b0;
            end

            //=========================================================
            // I-type ALU (OP-IMM)
            //=========================================================
            OPCODE_OP_IMM: begin
                reg_write       = 1'b1;
                wb_sel          = 3'b000; // ALU result

                alu_src         = 1'b1;   // imm
                alu_op          = 2'b11;  // I-type decode
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b0;
                mem_write       = 1'b0;

                branch          = 1'b0;
                jump            = 1'b0;
                jalr            = 1'b0;
            end

            //=========================================================
            // LOAD (lw)
            //=========================================================
            OPCODE_LOAD: begin
                reg_write       = 1'b1;
                wb_sel          = 3'b001; // memory data

                alu_src         = 1'b1;   // base + imm
                alu_op          = 2'b00;  // ADD
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b1;
                mem_write       = 1'b0;

                branch          = 1'b0;
                jump            = 1'b0;
                jalr            = 1'b0;
            end

            //=========================================================
            // STORE (sw)
            //=========================================================
            OPCODE_STORE: begin
                reg_write       = 1'b0;

                alu_src         = 1'b1;   // base + imm
                alu_op          = 2'b00;  // ADD
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b0;
                mem_write       = 1'b1;

                branch          = 1'b0;
                jump            = 1'b0;
                jalr            = 1'b0;
            end

            //=========================================================
            // BRANCH
            //=========================================================
            OPCODE_BRANCH: begin
                reg_write       = 1'b0;

                alu_src         = 1'b0;   // rs2 used in compare sometimes
                alu_op          = 2'b01;  // branch -> SUB (mainly for BEQ/BNE)
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b0;
                mem_write       = 1'b0;

                branch          = 1'b1;
                jump            = 1'b0;
                jalr            = 1'b0;
            end

            //=========================================================
            // JAL
            //=========================================================
            OPCODE_JAL: begin
                reg_write       = 1'b1;
                wb_sel          = 3'b010; // PC+4

                alu_src         = 1'b0;
                alu_op          = 2'b00;
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b0;
                mem_write       = 1'b0;

                branch          = 1'b0;
                jump            = 1'b1;
                jalr            = 1'b0;
            end

            //=========================================================
            // JALR
            //=========================================================
            OPCODE_JALR: begin
                reg_write       = 1'b1;
                wb_sel          = 3'b010; // PC+4

                alu_src         = 1'b1;   // rs1 + imm
                alu_op          = 2'b00;  // ADD
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b0;
                mem_write       = 1'b0;

                branch          = 1'b0;
                jump            = 1'b0;
                jalr            = 1'b1;
            end

            //=========================================================
            // LUI
            //=========================================================
            OPCODE_LUI: begin
                reg_write       = 1'b1;
                wb_sel          = 3'b011; // U-immediate directly

                alu_src         = 1'b0;
                alu_op          = 2'b00;
                use_pc_as_alu_a = 1'b0;

                mem_read        = 1'b0;
                mem_write       = 1'b0;

                branch          = 1'b0;
                jump            = 1'b0;
                jalr            = 1'b0;
            end

            //=========================================================
            // AUIPC
            //=========================================================
            OPCODE_AUIPC: begin
                reg_write       = 1'b1;
                wb_sel          = 3'b100; // PC + imm

                alu_src         = 1'b1;   // imm
                alu_op          = 2'b00;  // ADD
                use_pc_as_alu_a = 1'b1;   // A = PC

                mem_read        = 1'b0;
                mem_write       = 1'b0;

                branch          = 1'b0;
                jump            = 1'b0;
                jalr            = 1'b0;
            end

            default: begin
                // Leave defaults (NOP behavior)
            end

        endcase
    end

endmodule