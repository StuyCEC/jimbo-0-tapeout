
module ALU (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [3:0] mode,

    input wire carry_f,
    input wire borrow_f,

    output reg [3:0] c,
    output reg [3:0] flags
);

    always @(*) begin
        c = 4'b0000;
        flags = 4'b0000;

        case (mode)
            4'b0000: {flags[0], c} = {1'b0, a} + {1'b0, b};   
            4'b0001: {flags[0], c} = {1'b0, a} + {1'b0, b} + carry_f;  
            4'b0010: {flags[1], c} = {1'b0, a} - {1'b0, b};   
            4'b0011: {flags[1], c} = {1'b0, a} - {1'b0, b} - borrow_f;
            4'b0100: c = a << 1;
            4'b0101: c = a >> 1;
            4'b0110: c = a & b;
            4'b0111: c = a | b;
            4'b1000: c = ~a;
            4'b1009: c = a ^ b;
            4'b1010: c = ~(a & b);
            4'b1011: c = ~(a | b);
            default: c = 4'b0000;
        endcase

        flags[2] = (c == 4'b0000);
        flags[3] = (a < b);
    end

endmodule