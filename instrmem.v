module imem #(
    parameter MEM_DEPTH_WORDS = 1024                   // Total words in IMEM
)(
    input  wire [31:0] addr,                           // Byte address from PC
    output wire [31:0] instr                           // 32-bit instruction output
);

    //=================================================================
    // Instruction Memory Storage
    //=================================================================
    // Each entry is one 32-bit RISC-V instruction word.
    // MEM_DEPTH_WORDS = number of 32-bit words.
    //=================================================================
    reg [31:0] mem [0:MEM_DEPTH_WORDS-1];

    //=================================================================
    // Address Mapping (Word Addressing)
    //=================================================================
    // RISC-V instructions are 4-byte aligned.
    // So:
    //   PC = byte address
    //   Index = PC / 4 = PC[31:2]
    //=================================================================
    wire [$clog2(MEM_DEPTH_WORDS)-1:0] word_index;
    assign word_index = addr[31:2];

    //=================================================================
    // Combinational Read Output
    //=================================================================
    // Reads instruction directly from memory.
    // No clock required (ROM-like).
    //=================================================================
    assign instr = mem[word_index];

endmodule