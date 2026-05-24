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
        // Check for the new SLL instruction result
        if(DataAdr === 104 & WriteData === 200) begin
          $display("Simulation succeeded");
          $stop;
          
        // Fail ONLY if it writes to an unexpected address
        // (Addresses 96 and 100 are expected from the earlier parts of the test program)
        end else if (DataAdr !== 96 & DataAdr !== 100) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule
