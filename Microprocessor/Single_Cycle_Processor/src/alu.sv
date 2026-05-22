module alu_extended #(parameter N = 32) (
    input  logic [N-1:0] A, B,
    input  logic [2:0]   ALUControl,
    output logic [N-1:0] Result,
    output logic         Cout,
    output logic         Overflow
);
    logic [N-1:0] Bout;
    logic [N-1:0] Sum;
    logic         slt_result;

    // 2:1 Mux for B and Inverter
    assign Bout = ALUControl[0] ? ~B : B;

    // N-bit Adder
    assign {Cout, Sum} = A + Bout + ALUControl[0];

    // Overflow detection logic
    // Occurs if the signs of inputs match each other but differ from the sum
    // (Only evaluated during Add/Sub, where ALUControl[1] == 0)
    assign Overflow = ~(A[N-1] ^ Bout[N-1]) & (A[N-1] ^ Sum[N-1]) & ~ALUControl[1];

    // Set Less Than logic (Sum sign bit XOR Overflow)
    assign slt_result = Sum[N-1] ^ Overflow;

    // Main 5:1 Result Mux
    always_comb begin
        case (ALUControl)
            3'b000, 
            3'b001:  Result = Sum;                         // Add/Subtract
            3'b010:  Result = A & B;                       // AND
            3'b011:  Result = A | B;                       // OR
            3'b101:  Result = {{N-1{1'b0}}, slt_result};   // SLT (Zero Extended)
            default: Result = 'x;                          // Undefined
        endcase
    end
endmodule
