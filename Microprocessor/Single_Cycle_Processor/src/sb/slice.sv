module slice(
  input  logic [1:0]  MemSel, 
  input  logic [31:0] ReadData, 
  input  logic [31:0] WriteDataReg, 
  output logic [31:0] WriteData
);

  // Wrap the case statement in an always_comb block
  always_comb begin
    case (MemSel)
      2'b00:   WriteData = {ReadData[31:8], WriteDataReg[7:0]};
      2'b01:   WriteData = {ReadData[31:16], WriteDataReg[15:0]};
      2'b10:   WriteData = WriteDataReg;
      default: WriteData = WriteDataReg; // Fixed the capital 'R'
    endcase
  end

endmodule
