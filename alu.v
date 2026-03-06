module alu (
    input  wire [31:0] A,           // Operand A
    input  wire [31:0] B,           // Operand B
    input  wire [3:0]  ALUControl,  // ALU operation selector
    output reg  [31:0] Result,      // ALU result
    output reg         Carry,       // Carry-out (ADD/SUB)
    output reg         OverFlow,    // Signed overflow (ADD/SUB)
    output wire        Zero,        // Result == 0
    output wire        Negative     // Result[31]
);

    //=================================================================
    // Internal Signals for ADD/SUB
    //=================================================================
    // We use a 33-bit sum to capture carry-out.
    //=================================================================
    reg  [32:0] sum_ext;
    wire [31:0] B_sub;

    // For subtraction: use two's complement of B
    assign B_sub = ~B + 32'd1;

    //=================================================================
    // Combinational ALU
    //=================================================================
    always @(*) begin

        // Default outputs
        Result   = 32'h0000_0000;
        Carry    = 1'b0;
        OverFlow = 1'b0;
        sum_ext  = 33'd0;

        case (ALUControl)

            // ------------------------------------------------------
            // ADD
            // ------------------------------------------------------
            4'b0000: begin
                sum_ext = {1'b0, A} + {1'b0, B};
                Result  = sum_ext[31:0];
                Carry   = sum_ext[32];

                // Signed overflow:
                // if A and B have same sign, but Result has different sign
                OverFlow = (~(A[31] ^ B[31])) & (A[31] ^ Result[31]);
            end

            // ------------------------------------------------------
            // SUB
            // ------------------------------------------------------
            4'b0001: begin
                sum_ext = {1'b0, A} + {1'b0, B_sub};
                Result  = sum_ext[31:0];
                Carry   = sum_ext[32]; // 1 means no borrow

                // Signed overflow for subtraction:
                // if A and B have different sign, and Result sign differs from A
                OverFlow = (A[31] ^ B[31]) & (A[31] ^ Result[31]);
            end

            // ------------------------------------------------------
            // AND
            // ------------------------------------------------------
            4'b0010: begin
                Result = A & B;
            end

            // ------------------------------------------------------
            // OR
            // ------------------------------------------------------
            4'b0011: begin
                Result = A | B;
            end

            // ------------------------------------------------------
            // XOR
            // ------------------------------------------------------
            4'b0100: begin
                Result = A ^ B;
            end

            // ------------------------------------------------------
            // SLT (signed)
            // ------------------------------------------------------
            4'b0101: begin
                Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            end

            // ------------------------------------------------------
            // SLTU (unsigned)
            // ------------------------------------------------------
            4'b0110: begin
                Result = (A < B) ? 32'd1 : 32'd0;
            end

            // ------------------------------------------------------
            // SLL (logical left shift)
            // Only lower 5 bits of B used for shift amount (RV32 rule)
            // ------------------------------------------------------
            4'b0111: begin
                Result = A << B[4:0];
            end

            // ------------------------------------------------------
            // SRL (logical right shift)
            // ------------------------------------------------------
            4'b1000: begin
                Result = A >> B[4:0];
            end

            // ------------------------------------------------------
            // SRA (arithmetic right shift)
            // ------------------------------------------------------
            4'b1001: begin
                Result = $signed(A) >>> B[4:0];
            end

            // ------------------------------------------------------
            // Default
            // ------------------------------------------------------
            default: begin
                Result   = 32'h0000_0000;
                Carry    = 1'b0;
                OverFlow = 1'b0;
            end

        endcase
    end

    //=================================================================
    // Flags
    //=================================================================
    assign Zero     = (Result == 32'h0000_0000);
    assign Negative = Result[31];

endmodule