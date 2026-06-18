module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic        PCwrite,
    input  logic        AdrSrc,
    input  logic        IRWrite,
    input  logic [1:0]  ResultSrc,
    input  logic [2:0]  ALUControl,
    input  logic [1:0]  ALUSrcB,
    input  logic [1:0]  ALUSrcA,
    input  logic [1:0]  ImmSrc,
    input  logic        RegWrite,
    output logic [6:0]  op,
    output logic [2:0]  funct3,
    output logic        funct7_5,
    output logic        Zero,
    
    // Memory Interface (Appended here since they were missing from the snippet)
    input  logic [31:0] ReadData,
    output logic [31:0] DataAdr,
    output logic [31:0] WriteData
);

    // Internal wires
    logic [31:0] PC, OldPC, Instr, Data;
    logic [31:0] A;
    logic [31:0] ALUOut, ALUResult, Result;
    logic [31:0] SrcA, SrcB, ImmExt;
    logic [31:0] RD1, RD2;

    // Instruction decoding
    assign op       = Instr[6:0];
    assign funct3   = Instr[14:12];
    assign funct7_5 = Instr[30];

    // ==========================================
    // State Registers (Structural Instantiations)
    // ==========================================

    // PC Register (Only register with active reset, enabled by PCwrite)
    flopr32 pcreg (
        .clk(clk), 
        .reset(reset), 
        .en(PCwrite), 
        .d(Result), 
        .q(PC)
    );

    // OldPC and Instruction Register (Reset tied to 0, enabled by IRWrite)
    flopr32x2 oldpc_instr_reg (
        .clk(clk), 
        .en(IRWrite), 
        .reset(1'b0), 
        .d1(PC), 
        .d2(ReadData), 
        .q1(OldPC), 
        .q2(Instr)
    );

    // Data Register (Reset tied to 0, no enable in diagram -> tied to 1)
    flopr32 datareg (
        .clk(clk), 
        .reset(1'b0), 
        .en(1'b1), 
        .d(ReadData), 
        .q(Data)
    );

    // A and WriteData Pipeline Registers (Reset tied to 0, no enable in diagram -> tied to 1)
    flopr32x2 a_writedata_reg (
        .clk(clk), 
        .en(1'b1), 
        .reset(1'b0), 
        .d1(RD1), 
        .d2(RD2), 
        .q1(A), 
        .q2(WriteData) 
    );

    // ALUOut Register (Reset tied to 0, no enable in diagram -> tied to 1)
    flopr32 aluoutreg (
        .clk(clk), 
        .reset(1'b0), 
        .en(1'b1), 
        .d(ALUResult), 
        .q(ALUOut)
    );

    // ==========================================
    // Datapath Multiplexers
    // ==========================================

    // Address Mux (0: PC, 1: Result)
    mux2 #(32) adr_mux (
        .d0(PC), 
        .d1(Result), 
        .s(AdrSrc), 
        .y(Adr)
    );

    // ALU SrcA Mux (00: PC, 01: OldPC, 10: A)
    mux3 #(32) srca_mux (
        .d0(PC), 
        .d1(OldPC), 
        .d2(A), 
        .s(ALUSrcA), 
        .y(SrcA)
    );

    // ALU SrcB Mux (00: WriteData, 01: 4, 10: ImmExt)
    mux3 #(32) srcb_mux (
        .d0(WriteData), 
        .d1(32'd4), 
        .d2(ImmExt), 
        .s(ALUSrcB), 
        .y(SrcB)
    );

    // Result Mux (00: ALUOut, 01: Data, 10: ALUResult)
    mux3 #(32) result_mux (
        .d0(ALUOut), 
        .d1(Data), 
        .d2(ALUResult), 
        .s(ResultSrc), 
        .y(Result)
    );

    // ==========================================
    // Functional Units
    // ==========================================

    // Register File
    regfile rf (
        .clk(clk), 
        .we3(RegWrite), 
        .a1(Instr[19:15]), 
        .a2(Instr[24:20]), 
        .a3(Instr[11:7]), 
        .wd3(Result), 
        .rd1(RD1), 
        .rd2(RD2)
    );

    // Sign Extension
    extend ext (
        .instr(Instr[31:7]), 
        .immsrc(ImmSrc), 
        .immext(ImmExt)
    );

    // ALU
    alu alu_unit (
        .SrcA(SrcA), 
        .SrcB(SrcB), 
        .ALUControl(ALUControl), 
        .ALUResult(ALUResult), 
        .Zero(Zero)
    );

endmodule
