module alu(input  logic [31:0] SrcA, SrcB,
           input  logic [2:0]  ALUControl,
           output logic [31:0] ALUResult,
           output logic        Zero);

  logic [31:0] condinvb;
  logic [31:0] sum;
  logic        v; // overflow

  // 2:1 Mux for B and Inverter
  assign condinvb = ALUControl[0] ? ~SrcB : SrcB;

  // 32-bit Adder
  assign sum = SrcA + condinvb + ALUControl[0];

  // Overflow detection logic 
  // Evaluated during Add/Sub (where ALUControl[1] == 0)
  assign v = ~(SrcA[31] ^ condinvb[31]) & (SrcA[31] ^ sum[31]) & ~ALUControl[1];

  // Main Result Mux
  always_comb begin
    case (ALUControl)
      3'b000:  ALUResult = sum;                      // Add
      3'b001:  ALUResult = sum;                      // Subtract
      3'b010:  ALUResult = SrcA & SrcB;              // AND
      3'b011:  ALUResult = SrcA | SrcB;              // OR
      3'b101:  ALUResult = {31'b0, (sum[31] ^ v)};   // SLT (Zero Extended)
      3'b110: ALUResult = SrcA << SrcB[4:0];
      default: ALUResult = 32'bx;                    // Undefined
    endcase
  end

  // Zero flag
  assign Zero = (ALUResult == 32'b0);

endmodule
