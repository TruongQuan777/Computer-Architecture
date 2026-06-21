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
        // Check for the new auipc success condition
        if(DataAdr === 104 & WriteData === 32'h1050) begin 
          $display("Simulation succeeded: auipc verified!");
          $stop;
        end 
        // Ignore the expected writes to 96 and 100 from earlier in the assembly
        else if (DataAdr !== 96 & DataAdr !== 100) begin
          $display("Simulation failed: Unexpected write to Address %0d with Data %0h", DataAdr, WriteData);
          $stop;
        end
      end
    end
endmodule
