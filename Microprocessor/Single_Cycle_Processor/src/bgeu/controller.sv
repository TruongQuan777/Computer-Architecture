module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic       Zero,
                  input logic        CarryOut,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [2:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op[5], funct3, funct7b5, ALUOp, ALUControl);
  always_comb
    begin
      if (Jump) PCSrc=1;
      else if (Branch)
        begin
          case (funct3)
            3'b000: PCSrc=Zero;
            3'b111: PCSrc=CarryOut;
            default: PCSrc=0;
          endcase
        end
      else PCSrc=0;
    end
endmodule
