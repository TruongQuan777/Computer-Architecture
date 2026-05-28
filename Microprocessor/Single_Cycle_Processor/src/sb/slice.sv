module slice(input logic [1:0] MemSel, input ReadData, input WriteData, input WriteDataMem);
  case (MemSel)
    2'b00: WriteDataMem=WriteData;
    2'b01: WriteDataMem={ReadData[31:16],WriteData[15:0]};
    2'b10: WriteDataMem={ReadData[31:8],WriteData[7:0]};
  endcase
endmodule
