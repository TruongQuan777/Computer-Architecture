module maindec (
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    output logic [1:0] ALUOp,
    output logic       Branch,
    output logic       PCUpdate,
    output logic       RegWrite,
    output logic       MemWrite,
    output logic       IRWrite,
    output logic [1:0] ResultSrc,
    output logic [1:0] ALUSrcB,
    output logic [1:0] ALUSrcA,
    output logic       AdrSrc
);

    // State Encoding using localparam
    localparam logic [3:0] 
        S0_FETCH    = 4'd0,
        S1_DECODE   = 4'd1,
        S2_MEMADR   = 4'd2,
        S3_MEMREAD  = 4'd3,
        S4_MEMWB    = 4'd4,
        S5_MEMWRITE = 4'd5,
        S6_EXECUTER = 4'd6,
        S7_ALUWB    = 4'd7,
        S8_EXECUTEI = 4'd8,
        S9_JAL      = 4'd9,
        S10_BEQ     = 4'd10;

    // State registers
    logic [3:0] state, next_state;

    // Opcode Definitions
    localparam logic [6:0] 
        OP_LW      = 7'b0000011,
        OP_SW      = 7'b0100011,
        OP_RTYPE   = 7'b0110011,
        OP_ITYPE   = 7'b0010011,
        OP_JAL     = 7'b1101111,
        OP_BEQ     = 7'b1100011;
        OP_AUIPC   = 7'b0010111;

    // 1. State Register (Sequential)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= S0_FETCH;
        else       state <= next_state;
    end

    // 2. Next State Logic (Combinational)
    always_comb begin
        case (state)
            S0_FETCH:  next_state = S1_DECODE;
            
            S1_DECODE: begin
                if      (op == OP_LW || op == OP_SW) next_state = S2_MEMADR;
                else if (op == OP_RTYPE)             next_state = S6_EXECUTER;
                else if (op == OP_ITYPE)             next_state = S8_EXECUTEI;
                else if (op == OP_JAL)               next_state = S9_JAL;
                else if (op == OP_BEQ)               next_state = S10_BEQ;
                else if (op == OP_AUIPC)             next_state = S7_ALUWB;
                else                                 next_state = S0_FETCH; // Default safe state
            end
            
            S2_MEMADR: begin
                if      (op == OP_LW) next_state = S3_MEMREAD;
                else if (op == OP_SW) next_state = S5_MEMWRITE;
                else                  next_state = S0_FETCH; 
            end
            
            S3_MEMREAD:  next_state = S4_MEMWB;
            S4_MEMWB:    next_state = S0_FETCH;
            S5_MEMWRITE: next_state = S0_FETCH;
            
            S6_EXECUTER: next_state = S7_ALUWB;
            S8_EXECUTEI: next_state = S7_ALUWB;
            S9_JAL:      next_state = S7_ALUWB;
            
            S7_ALUWB:    next_state = S0_FETCH;
            S10_BEQ:     next_state = S0_FETCH;
            
            default:     next_state = S0_FETCH;
        endcase
    end

    // 3. Output Logic (Combinational)
    always_comb begin
        // Default enabling signals to 0
        Branch    = 1'b0;
        PCUpdate  = 1'b0;
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        IRWrite   = 1'b0;
        
        // Default mux selects to don't cares
        ALUOp     = 2'bxx;
        ResultSrc = 2'bxx;
        ALUSrcB   = 2'bxx;
        ALUSrcA   = 2'bxx;
        AdrSrc    = 1'bx;

        case (state)
            S0_FETCH: begin
                AdrSrc    = 1'b0;
                IRWrite   = 1'b1;
                ALUSrcA   = 2'b00;
                ALUSrcB   = 2'b10;
                ALUOp     = 2'b00;
                ResultSrc = 2'b10;
                PCUpdate  = 1'b1;
            end
            
            S1_DECODE: begin
                ALUSrcA   = 2'b01;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b00;
            end
            
            S2_MEMADR: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b00;
            end
            
            S3_MEMREAD: begin
                ResultSrc = 2'b00;
                AdrSrc    = 1'b1;
            end
            
            S4_MEMWB: begin
                ResultSrc = 2'b01;
                RegWrite  = 1'b1;
            end
            
            S5_MEMWRITE: begin
                ResultSrc = 2'b00;
                AdrSrc    = 1'b1;
                MemWrite  = 1'b1;
            end
            
            S6_EXECUTER: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b10;
            end
            
            S8_EXECUTEI: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b10;
            end
            
            S9_JAL: begin
                ALUSrcA   = 2'b01;
                ALUSrcB   = 2'b10;
                ALUOp     = 2'b00;
                ResultSrc = 2'b00;
                PCUpdate  = 1'b1;
            end
            
            S7_ALUWB: begin
                ResultSrc = 2'b00;
                RegWrite  = 1'b1;
            end
            
            S10_BEQ: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b01;
                ResultSrc = 2'b00;
                Branch    = 1'b1;
            end
            
            default: begin
                // All defaults already handled at the top of the block
            end
        endcase
    end

endmodule
