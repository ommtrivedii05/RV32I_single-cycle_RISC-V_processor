module dmem #(
    parameter DEPTH = 256                // Number of 32-bit words
)(
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,             // Byte address
    input  wire [31:0] write_data,       // Data to store
    output reg  [31:0] read_data         // Data loaded
);

    //=================================================================
    // Memory array (word-addressed)
    //=================================================================
    reg [31:0] mem [0:DEPTH-1];

    //=================================================================
    // Word index extraction
    //=================================================================
    // We assume aligned accesses, so addr[1:0] = 00.
    // Use addr[31:2] for word indexing.
    //=================================================================
    wire [31:0] word_index;
    assign word_index = addr >> 2;

    //=================================================================
    // Combinational read
    //=================================================================
    always @(*) begin
        if (mem_read)
            read_data = mem[word_index];
        else
            read_data = 32'h0000_0000;
    end

    //=================================================================
    // Synchronous write (posedge)
    //=================================================================
    always @(posedge clk) begin
        if (mem_write)
            mem[word_index] <= write_data;
    end

endmodule