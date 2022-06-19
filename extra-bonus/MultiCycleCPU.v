`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: MultiCycleCPU
// Project Name: Multi-cycle-cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MultiCycleCPU (reset, clk, a0, v0, sp, ra);
    // Input Clock Signals
    input reset;
    input clk;
    output [15:0] a0, v0, sp, ra;
    assign a0 = u_RegisterFile.RF_data[4];
    assign v0 = u_RegisterFile.RF_data[2];
    assign sp = u_RegisterFile.RF_data[29];
    assign ra = u_RegisterFile.RF_data[31];
    
    // control signals
    wire PCWrite;
    wire PCWriteCond;
    wire [1:0] IorD;        
    wire MemWrite;
    wire MemRead;
    wire IRWrite;
    wire [2:0] MemtoReg;
    wire [1:0] RegDst;    
    wire RegWrite;
    wire ExtOp;
    wire LuiOp;
    wire [1:0] ALUSrcA;   
    wire [1:0] ALUSrcB; 
    wire [3:0] ALUOp;
    wire [1:0] PCSource;  

    // Memory
    wire [31:0] PC;
    wire [31:0] Mem_data;
    wire [31:0] Address;
    wire [31:0] Write_data_mem;
    
    InstAndDataMemory_2 u_InstAndDataMemory(
    	.reset      (reset           ),
        .clk        (clk             ),
        .Address    (Address         ),
        .Write_data (Write_data_mem  ),
        .MemRead    (MemRead         ),
        .MemWrite   (MemWrite        ),
        .Mem_data   (Mem_data        )
    );

    // InstReg
    wire [5:0]  OpCode;
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [4:0]  rd;
    wire [4:0]  Shamt;
    wire [5:0]  Funct;
    wire [31:0] Instruction;

    assign Instruction = {OpCode, rs, rt, rd, Shamt, Funct};

    InstReg u_InstReg(
    	.reset       (reset       ),
        .clk         (clk         ),
        .IRWrite     (IRWrite     ),
        .Instruction (Mem_data    ),
        .OpCode      (OpCode      ),
        .rs          (rs          ),
        .rt          (rt          ),
        .rd          (rd          ),
        .Shamt       (Shamt       ),
        .Funct       (Funct       )
    );

    // Controller
    Controller_2 u_Controller(
    	.reset       (reset       ),
        .clk         (clk         ),
        .OpCode      (OpCode      ),
        .Funct       (Funct       ),
        .PCWrite     (PCWrite     ),
        .PCWriteCond (PCWriteCond ),
        .IorD        (IorD        ),
        .MemWrite    (MemWrite    ),
        .MemRead     (MemRead     ),
        .IRWrite     (IRWrite     ),
        .MemtoReg    (MemtoReg    ),
        .RegDst      (RegDst      ),
        .RegWrite    (RegWrite    ),
        .ExtOp       (ExtOp       ),
        .LuiOp       (LuiOp       ),
        .ALUSrcA     (ALUSrcA     ),
        .ALUSrcB     (ALUSrcB     ),
        .ALUOp       (ALUOp       ),
        .PCSource    (PCSource    )
    );

    // MDR
    wire [31:0] MDR_Out;
    // Reg 1
    RegTemp MDR(
    	.reset  (reset    ),
        .clk    (clk      ),
        .Data_i (Mem_data ),
        .Data_o (MDR_Out  )
    );
    
    wire [4:0] Write_register;
    // MUX 1
    assign Write_register = (RegDst == 2'b00) ? rt :
                            (RegDst == 2'b01) ? rd :
                            5'd31;      // rt, rd, $ra
    wire [31:0] Write_data_rf;
    wire [31:0] Read_data1;
    wire [31:0] Read_data2;

    RegisterFile u_RegisterFile(
    	.reset          (reset          ),
        .clk            (clk            ),
        .RegWrite       (RegWrite       ),
        .Read_register1 (rs             ),
        .Read_register2 (rt             ),
        .Write_register (Write_register ),
        .Write_data     (Write_data_rf  ),
        .Read_data1     (Read_data1     ),
        .Read_data2     (Read_data2     )
    );

    // Reg 2
    wire [31:0] RegAOut;
    RegTemp RegA(
    	.reset  (reset      ),
        .clk    (clk        ),
        .Data_i (Read_data1 ),
        .Data_o (RegAOut    )
    );

    // Reg 3
    wire [31:0] RegBOut;
    RegTemp RegB(
    	.reset  (reset      ),
        .clk    (clk        ),
        .Data_i (Read_data2 ),
        .Data_o (RegBOut    )
    );
    
    // ALUControl
    wire [4:0] ALUConf;
    wire Sign;
    ALUControl u_ALUControl(
    	.ALUOp   (ALUOp   ),
        .Funct   (Funct   ),
        .ALUConf (ALUConf ),
        .Sign    (Sign    )
    );
    
    // Ext
    wire [15:0] Immediate;
    wire [31:0] ImmExtOut;
    wire [31:0] ImmExtShift;
    assign Immediate = Instruction[15:0];
    ImmProcess u_ImmProcess(
    	.ExtOp       (ExtOp       ),
        .LuiOp       (LuiOp       ),
        .Immediate   (Immediate   ),
        .ImmExtOut   (ImmExtOut   ),
        .ImmExtShift (ImmExtShift )
    );
    
    // ALU
    wire [31:0] In1;
    wire [31:0] In2;
    wire Zero;
    wire [31:0] Result;
    // MUX 2
    assign In1 = (ALUSrcA == 2'b00) ? PC :
                 (ALUSrcA == 2'b01) ? RegAOut :
                 Shamt;     // PC: RegAOut: Shamt
    // MUX 3
    assign In2 = (ALUSrcB == 2'b00) ? RegBOut : 
                 (ALUSrcB == 2'b01) ? 32'd4 :
                 (ALUSrcB == 2'b10) ? ImmExtOut:
                 ImmExtShift;
    ALU u_ALU(
    	.ALUConf (ALUConf ),
        .Sign    (Sign    ),
        .In1     (In1     ),
        .In2     (In2     ),
        .Zero    (Zero    ),
        .Result  (Result  )
    );
    
    // Reg 4
    wire [31:0] ALUOut;
    RegTemp RegALU(
    	.reset  (reset  ),
        .clk    (clk    ),
        .Data_i (Result ),
        .Data_o (ALUOut )
    );
    
    // PC
    wire [31:0] PC_i;
    // MUX 4
    assign PC_i = (PCSource == 2'b00) ? Result :
                  (PCSource == 2'b01) ? ALUOut :
                  {PC[31:28], Instruction[25:0], 2'b00};
    wire PCWriteENA;
    assign PCWriteENA = (PCWrite == 1'b1) || (PCWriteCond && Zero); 
    PC u_PC(
    	.reset   (reset     ),
        .clk     (clk       ),
        .PCWrite (PCWriteENA),
        .PC_i    (PC_i      ),
        .PC_o    (PC        )
    );
    
    // MEM
    // MUX 5
    assign Address = (IorD == 2'b10) ? Result :
                     ((IorD == 1'b0) ? PC : ALUOut);
    assign Write_data_mem = RegBOut;

    // RF
    // MUX 6
    assign Write_data_rf = (MemtoReg == 2'b00) ? MDR_Out :
                           (MemtoReg == 2'b01) ? ALUOut  :
                           (MemtoReg == 2'b10) ? PC      :
                           (MemtoReg == 2'b11) ? Result  :
                           Mem_data;

endmodule