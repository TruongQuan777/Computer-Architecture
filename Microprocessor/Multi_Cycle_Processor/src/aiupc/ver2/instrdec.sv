module instrdec(
    input  logic [6:0] op,
    output logic [2:0] ImmSrc
);

    always_comb begin
        case(op)
            7'b0000011: ImmSrc = 3'b00; // lw
            7'b0100011: ImmSrc = 3'b01; // sw
            7'b0110011: ImmSrc = 3'bxx; // R-type (Don't care)
            7'b1100011: ImmSrc = 3'b10; // beq
            7'b0010011: ImmSrc = 3'b00; // I-type ALU
            7'b1101111: ImmSrc = 3'b11; // jal
            7'b0010111: ImmSrc = 3'b100; // U-type
            default:    ImmSrc = 2'bxx; // Default case for safety
        endcase
    end

endmodule
