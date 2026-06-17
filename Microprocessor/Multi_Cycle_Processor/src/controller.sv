module controller (input logic clk, 
                   output logic PCwrite, AdrSrc, MemWrite, IRWrite, 
                   output logic [1:0] ResultSrc, 
                   output logic [2:0] ALUControl, 
                   output logic [1:0] ALUSrcB, ALUSrcA, ImmSrc, 
                   output logic RegWrite, 
                   input logic [6:0] op, 
                   input logic [2:0] funct3, 
                   input logic funct7b5, input logic Zero);

  logic [1:0] ALUOp;
  logic       Branch,PCUpdate;
  maindec md (op, ALUop, Branch, PCUpdate, RegWrite, MemWrite, IRWrite, ResultSrc, ALUSrcB, ALUSrcA, AdrSrc);
  aludec ad (ALUOp, op, funct3, funct7b5, ALUControl);
  instrdec id (op,ImmSrc);
  assign PCWrite = Branch & Zero | PCUpdate;
endmodule
