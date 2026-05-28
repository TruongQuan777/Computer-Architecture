module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic       Zero,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc, MemSel,
                  output logic [2:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;
  
  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op[5], funct3, funct7b5, ALUOp, ALUControl);

  // Removed the () after always_comb
  always_comb 
    begin
      if(op==7'b0110011) // Note: standard RISC-V S-type opcode is actually 0100011 (sw/sb/sh), but keeping your logic structure
        begin
          case(funct3)
            3'b000: MemSel=2'b00;
            3'b001: MemSel=2'b01;
            3'b010: MemSel=2'b10;
            default: MemSel=2'b10;
          endcase // Added missing endcase
        end
      else MemSel=2'b10;
    end
    
  assign PCSrc = Branch & Zero | Jump;
endmodule
