module flopr32(input  logic   clk, reset, en, 
                 input  logic [31:0] d,
                 output logic [31:0] q);

  always_ff @(posedge clk)
    begin
      if(reset) q<=0;
      else q<=(en)?d:q;
    end

endmodule
