module flopr32x2(
    input  logic        clk, reset, en, 
    input  logic [31:0] d1, d2,   
    output logic [31:0] q1, q2
);

  always_ff @(posedge clk)
      begin
           if(reset) 
               begin
                   q1<=0;
                   q2<=0;
               end
           else
               begin
                   q1<=(en)?d1:q1;
                   q2<=(en)?d2:q2;
               end
      end
     
endmodule
