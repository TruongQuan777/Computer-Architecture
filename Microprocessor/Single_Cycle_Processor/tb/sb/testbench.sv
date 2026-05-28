module testbench();

  logic        clk;
  logic        reset;
  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  // instantiate device to be tested
  top dut(clk, reset, WriteData, DataAdr, MemWrite);

  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check results
  always @(negedge clk)
    begin
      if(MemWrite) begin
        // 1. Check for the SB success at address 108
        // We check if the lowest byte is 30 (since x2 = 25 + 5 = 30)
        if(DataAdr === 108 & WriteData[7:0] === 8'd30) begin
          $display("Simulation succeeded");
          $stop;
          
        // 2. Fail ONLY if it writes to an unexpected address
        // (Must ignore BOTH 96 and 100 to let the original program finish)
        end else if (DataAdr !== 96 & DataAdr !== 100) begin 
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule
