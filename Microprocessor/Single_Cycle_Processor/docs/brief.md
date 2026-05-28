# Single Cycle Processor
This directory contain my work on customizing a single-cycle processor. Many of the verilog files here are taken from the book "Digital Design and Computer Architecture, RISC-V Edition" by Sarah Harris. Others are my own design
## Folder structure
The original control unit, datapath, and other building blocks are copied from the book above for convenience and placed directly under the /src directory. The original testbench and memory files from the Sarah Harris book are placed under the /tb directory. 

Customized files are organized under directories of the form /<additional_instruction> inside both the /src and /tb folders (for example, /src/bgeu or /tb/bgeu).
## Single cycle processor structure
### Top module structure & hierarchy when view in Vivado Xilinx:

<img width="586" height="455" alt="image" src="https://github.com/user-attachments/assets/c33ba51e-47f3-4178-a313-522f34f26afe" />
<img width="339" height="478" alt="image" src="https://github.com/user-attachments/assets/b13e2a92-f99a-4aeb-90d3-abc8cde99bb0" />

### Datapath structure:

<img width="1175" height="655" alt="image" src="https://github.com/user-attachments/assets/aa06cede-c0f7-4453-9e9f-62692957aec5" />

### Controller structure:

<img width="562" height="536" alt="image" src="https://github.com/user-attachments/assets/2dbc1342-af59-45d2-97f5-6dfad6fdf0a8" />

### Main decoder truth table:

<img width="1236" height="411" alt="image" src="https://github.com/user-attachments/assets/2da25d05-09f4-46c2-8b82-2ec483550dce" />

## Single cycle processor for instructions set: lw,sw, R-type (add, or, and, slt), beq, addi, jal
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
### tb
- Memory file:
+ Append the SLL instruction to the end of the original riscvtest.txt and see if the latest instruction is ran through.
+ Have to ensure the proogram run fine up until the SLL instructions.

- Testbench: Use ChatGPT lol.
