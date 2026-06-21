# Multi Cycle Processor
This directory contain my work on customizing a Multi-cycle processor. Many of the verilog files here are taken from the book "Digital Design and Computer Architecture, RISC-V Edition" by Sarah Harris. Others are my own design
## Folder structure
The original control unit, datapath, and other building blocks are copied from the book above for convenience and placed directly under the /src directory. The original testbench and memory files from the Sarah Harris book are placed under the /tb directory. 

Customized files are organized under directories of the form /<additional_instruction> inside both the /src and /tb folders (for example, /src/xor or /tb/xor).
## Multi cycle processor structure
Any modules that is mentioned in this section are modules that have some adjustment compared to their version in the single-cycle processor section. For other modules not mentioned, reuse the one in the single-cycle processor section (but need to double check if there is really no need for any change).
### Top module structure & hierarchy when view in Vivado Xilinx:
<img width="409" height="549" alt="image" src="https://github.com/user-attachments/assets/230671a2-3081-4789-900d-25c8f71346ad" />



```systemverilog
module top(input  logic        clk, reset,
           output logic [31:0] WriteData, DataAdr,
           output logic        MemWrite);
           
  logic [31:0] ReadData;

  // instantiate processor and memories
  riscvmulti rvmulti(clk, reset, MemWrite, DataAdr, 
                     WriteData, ReadData);
  mem mem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule
```
### Riscvmulti module

<img width="2048" height="1206" alt="image" src="https://github.com/user-attachments/assets/c6b7ad58-bcb5-471d-b203-e633a2e2fddc" />


### Datapath structure:

<img width="2048" height="690" alt="image" src="https://github.com/user-attachments/assets/45456b79-7cf7-4d4a-a473-54cf31850f54" />


### Controller structure:

<img width="1644" height="1620" alt="image" src="https://github.com/user-attachments/assets/f423945d-9b5a-4755-aec1-48fe91bb5cc8" />

### Main decoder FSM:

<img width="714" height="526" alt="image" src="https://github.com/user-attachments/assets/47c27719-33e1-44eb-9f5c-ce06a8d4101d" />

### Instruction decoder:

A complete new block inside the main decoder. However, its structure remain simple ==> Can check in the repo for its SV code.

### Generic building blocks
#### Memory
We merge both the instruction and data into same memory block:

```systemverilog
module mem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  initial $readmemh("riscvtest.txt",RAM);
  
  assign rd = RAM[a[31:2]]; // word aligned

  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule
```

One thing worth note here is the fact that we assign rd = RAM [a[31:2]], which is equivalent to divide the data address a with 4 first before extracting the value of that address. The  reason we do so is we can only access memory every 4 bytes. Therefore, instead of saying "We access the word at 0, 4, 8... bytes", we divide its value by 4 and now can say "We access the 0th, 1st, 2nd, 3rd words"
#### Other generic building blocks
```systemverilog
module flopr32(input  logic   clk, reset, en, 
                 input  logic [31:0] d,
                 output logic [31:0] q);

  always_ff @(posedge clk)
    begin
      if(reset) q<=0;
      else q<=(en)?d:q;
    end

endmodule
```

```systemverilog
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
```
flopr32 is a D-flipflop with a single 32-bit input. flopr32x2 is the same module but with two 32-bit inputs. One thing we may notice is that in the datapath diagram, not every flipflop need the reset or en input. If that is the case, we can still use flopr32 and flopr32x2 but we tie  the reset pin to 0 and enable pin to 1.

## Debugging tips using Xilinx Vivado:

### Scope:

<img width="465" height="668" alt="image" src="https://github.com/user-attachments/assets/a2f42d6c-bbd1-4c75-b303-b3959eccf95b" />

This tell us the whole hierarchy tree of the dut (aka our top module) in the simulation. For each instance appears here, we can see its instance name and its module name (design unit name) which is helpful for debugging.

### Check waveform
To check the signal of any cells, navigate to its name in the Scope section, then:

1/ Right click on that instance and choose "Add to Wave window"

<img width="727" height="577" alt="image" src="https://github.com/user-attachments/assets/f9a1be97-2c6e-4388-8dee-9169f839b296" />

2/ Create a new group in Waveform interface

<img width="442" height="917" alt="image" src="https://github.com/user-attachments/assets/f49b5d91-87b7-43d0-a731-6d9b073378af" />


3/ Press ctrl and select all the signal of that instance and put to that group

<img width="123" height="168" alt="image" src="https://github.com/user-attachments/assets/6316bf7e-fd9c-4f76-96ed-27a57731ee6c" />


4/ Type "restart" in Tcl console. Press f3 to rerun simulation.

## auipc instruction
### Version 1
We realize that at stage S1: ALUResult = OldPC+ImmExt. Therefore, if we adjust the S1 state such that **if op==auipc, WD3=ALUResult then 1 clockedge after the S1 state**, the value OldPC+ImmExt is stored into rd inside reg file. As a result,the flow for auipc instruction only contains S0 and S1_adjusted.\

Pros: Only require **2 clock cycle**

Cons: Have to modify the S0, S1 of the controller. Even worse, this adjustment will make the controller not Moore type anymore. Before this change, control signal depends only on the state (Moore type). After this change, the control signal will depends on both the state and the op input (**Mealy type**). While this is not a bad thing, it may makes further adjustment in the future complicated. 
### Version 2
<img width="1178" height="1000" alt="image" src="https://github.com/user-attachments/assets/eb956581-2b8d-4f7a-bce5-7f56be6cdad2" />

The **maindec** should behave exactly like the FSM above. After S1, it transitions directly to S7, where PC + ImmExt is written to rd. 

However, there is one additional adjustment required. Different instructions require different methods of extending the immediate. In the **instrcdec** module, the immediate extension control signal (ImmSrc) has already been defined for all instruction types except the U-type instruction. Therefore, we need to modify the instrdec so that when op == AUIPC, ImmSrc is set to 3'b100. Then, in the **extend** module, we define ImmSrc = 3'b100 to indicate that the immediate should be extended by appending 12 zeros to its least significant end. We also need to widen the ImmSrc input from 2 bits to 3 bits. As a result, corresponding changes must be made to the **controller, datapath, extend,** and **riscvmulti** modules to accommodate the increased width of the ImmSrc signal.

### Controller
- Normally, PCSr will be 0 ==> PC_next=PC+4. When Jump or Branch condition is met, PCSrc is set to 0 ==> PC_next=PC+offset.
#### main_dec:
- Input: op[6:0]
- Output:
+ ResultSrc: 1 when the result are taken from the memory data. 0 when the result is taken from the ALU. 
+ MemWrite: 1 when we need to write to the memory.
+ ALUSrc: 1 when one of the operand is an immediate. 0 when the operands are from registers.
+ ImmSrc: Below is the picture on different ways to generate the final 32-bit immediate from the users code.

<img width="1239" height="190" alt="image" src="https://github.com/user-attachments/assets/d1a42eef-4164-4f40-93b8-492ba147feb8" />


+ RegWrite: 1 when we need to write information ont the register file.
#### alu_dec:
- Input: op[6:0], funct3[2:0], funct7[5]
- Output: ALU_control. 

### Datapath
#### ALU
- Input: SrcA, SrcB, ALU_control
- Output: ALU_Result, Flags (Zero, CarryOut...). In RISC-V, the Flags are updating automatically everytime we calculate ALU_result.
### Testbench & Memory file
#### Testbench
#### Memory file

<img width="632" height="881" alt="image" src="https://github.com/user-attachments/assets/5983806a-a3a2-41d6-91ff-49c79ae81e59" />

## Single cycle processor for additional instruction: SLL
### src
- Firstly, we choose a similiar instruction to SLL. The closest instruction is another R-type instruction, in this case ADD. For this case, the flow of the data is ... (view in book).
- Secondly, we imagine how the flow of SLL would be. It would be the same as ADD, but the alu will perform SLL instead of ADD. Since the ALUControl comes from the aludec, the aludec need to change.
- Thirdly, we double check: The direct modules that will see this change of **aludec** are maindec and the direct modules that see the change of **alu** is datapath. However, since the ports of the alu and aludec doesnt change, we dont need to change maindec and datapath. 
### tb
- Memory file:
+ Append the SLL instruction to the end of the original riscvtest.txt and see if the latest instruction is ran through.
+ Have to ensure the proogram run fine up until the SLL instructions.

- Testbench: Use ChatGPT lol.
## Single cycle processor for additional instruction: BGEU
### src
- Firstly, we choose a similiar instruction that is BEQ. For this case, the flow is...
- Secondly, the flow of BGEU would be the same as BEQ, however, it would require a way to check for the GE condition. We have to change the **alu** to create another flag which is OverFlow. This flag is fedback to the **controller** and we will use this flag in a new logic assignment for the PCSrc in the controller:
```systemverilog
always_comb
    begin
      if (Jump) PCSrc=1;
      else if (Branch)
        begin
          case (funct3)
            3'b000: PCSrc=Zero;
            3'b111: PCSrc=CarryOut;
            default: PCSrc=0;
          endcase
        end
      else PCSrc=0;
    end
```
- Thirdly, we double check: Datapath see that alu have change of port ==> **Datapath** change. Riscvsingle see that controller have change of port while datapath remain the same ==> **riscvsingle** still change 
### tb
Same as above
## Single cycle processor for additional instruction: SB
### src
- Firstly, choose a similiar instruction that is SB. For this case, the flow is...
- Secondly, the flow of SB would be same as SW, except for such things: 
+ Since the dmem cannot be written in byte, we have to append the 24 MSB of ReadData with 8 LSB of WriteData depends on MemSel. This require a **slice.sv** module that act as below:
```systemverilog
always_comb begin
    case (MemSel)
      2'b00:   WriteData = {ReadData[31:8], WriteDataReg[7:0]};
      2'b01:   WriteData = {ReadData[31:16], WriteDataReg[15:0]};
      2'b10:   WriteData = WriteDataReg;
      default: WriteData = WriteDataReg; 
    endcase
  end
```
+ The MemSel is generated by the **controller**. The maindec and aludec wont be change as the MemSel depends on both op anf funct, but we cannot change aludec if we dont change the ALU:
```systemverilog
always_comb 
    begin
      if(op==7'b0110011) 
        begin
          case(funct3)
            3'b000: MemSel=2'b00;
            3'b001: MemSel=2'b01;
            3'b010: MemSel=2'b10;
            default: MemSel=2'b10;
          endcase 
        end
      else MemSel=2'b10;
    end
```
- Thirdly, we double check:
+ The **dapath** would require a change because we create a new slice module inside it:

<img width="1437" height="798" alt="image" src="https://github.com/user-attachments/assets/5a458f74-31d2-401e-95ff-ab01898721e8" />


+ Since both the datapath and controller have a new ports (controller), we need to change **riscvsingle**.
+ The top module wont see any change of  riscvsingle or datapaths port. All of the structure relating to slice is hidden in riscvsingle and datapath.

### tb
Same
## Summary of technique
1/ Find which **instruction is the most similiar**: same op-code... And check the data flow when program try to resolve that instruction

2/ Imagine what would be the flow of the additional instruction. Does it** require another operation on the alu (SLL)** or **another flag from the alu (BGEU)** or since the memory cannot perform Byte data writing, we have to **create a slice module to handle this (SB)**

3/ Double check: For all the changes in 2/, **check which module can observe this change (change of ports mostly)**. Those modules also need to change. We keep doing so until no module need to change.

