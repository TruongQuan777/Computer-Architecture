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
Normally, PCSr will be 0 ==> PC_next=PC+4. When Jump or Branch condition is met, PCSrc is set to 0 ==> PC_next=PC+offset.


### Datapath

