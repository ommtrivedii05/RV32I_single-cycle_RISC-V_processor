module pc_next_logic (
    input  wire [31:0] pc_current,    // Current PC
    input  wire [31:0] rs1_val,       // rs1 value (for jalr)
    input  wire [31:0] imm_i,         // I-type immediate
    input  wire [31:0] imm_b,         // B-type immediate
    input  wire [31:0] imm_j,         // J-type immediate

    input  wire        branch,        // branch instruction
    input  wire        take_branch,   // branch condition result
    input  wire        jump,          // jal instruction
    input  wire        jalr,          // jalr instruction

    output reg  [31:0] pc_next,       // Next PC
    output wire [31:0] pc_plus4       // PC + 4
);

    //=================================================================
    // PC + 4 calculation
    //=================================================================
    assign pc_plus4 = pc_current + 32'd4;

    //=================================================================
    // Combinational PC next selection logic
    //=================================================================
    always @(*) begin

        // Default: sequential execution
        pc_next = pc_plus4;

        // Priority 1: JALR (highest priority)
        if (jalr) begin
            // Spec: clear bit0 of target address
            pc_next = (rs1_val + imm_i) & 32'hFFFF_FFFE;
        end

        // Priority 2: JAL
        else if (jump) begin
            pc_next = pc_current + imm_j;
        end

        // Priority 3: Branch taken
        else if (branch && take_branch) begin
            pc_next = pc_current + imm_b;
        end

        // Else: pc_next stays pc_plus4
    end

endmodule