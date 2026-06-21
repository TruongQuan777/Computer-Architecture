module riscvmulti (
    input  logic        clk,
    input  logic        reset,
    output logic        MemWrite,
    output logic [31:0] DataAdr,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData
);
logic PCWrite, AdrSrc,IRWrite;
logic [1:0] ResultSrc;
logic [2:0] ALUControl;
logic [1:0] ALUSrcB,ALUSrcA;
logic [2:0] ImmSrc;
logic RegWrite;
logic [31:0] Instr;
logic Zero;

controller c(clk, reset, PCWrite, AdrSrc, MemWrite, IRWrite, ResultSrc, ALUControl, ALUSrcB, ALUSrcA, ImmSrc, RegWrite, Instr[6:0], Instr[14:12], Instr[30], Zero);
datapath dp(clk, reset, PCWrite, AdrSrc, IRWrite, ResultSrc, ALUControl, ALUSrcB, ALUSrcA, ImmSrc, RegWrite, Instr[6:0], Instr[14:12], Instr[30], Zero, ReadData, DataAdr, WriteData);
endmodule
