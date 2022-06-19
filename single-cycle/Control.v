
module Control(OpCode, Funct,
	PCSrc, Branch, RegWrite, RegDst, 
	MemRead, MemWrite, MemtoReg, 
	ALUSrc1, ALUSrc2, ExtOp, LuOp);

	input [5:0] OpCode;
	input [5:0] Funct;
	output [1:0] PCSrc;
	output Branch;
	output RegWrite;
	output [1:0] RegDst;
	output MemRead;
	output MemWrite;
	output [1:0] MemtoReg;
	output ALUSrc1;
	output ALUSrc2;
	output ExtOp;
	output LuOp;
	
	assign PCSrc = (OpCode == 6'h04)? 2'd1 
    : (OpCode == 6'h02 || OpCode == 6'h3 ) ? 2'd2
    : (OpCode == 6'h0 && (Funct == 6'h08 || Funct == 6'h09))? 2'd3
    : 2'd0;             // beq? 1: j, jal? 2: jr, jarl? 3:0
    assign Branch = (OpCode == 6'h04);       
                        // beq
    assign RegWrite = (OpCode == 6'h2b || OpCode == 6'h04 || OpCode == 6'h02 || (OpCode == 6'h0 && Funct == 6'h08))? 1'b0
    : 1'b1;             // sw, beq, j, jr? 0:1
    assign RegDst = (OpCode == 6'h09 || OpCode == 6'h08 || OpCode == 6'h23 ||
     OpCode == 6'h0f || OpCode == 6'h0a || OpCode == 6'h0b || OpCode == 6'h0c) ? 2'd1
    : (OpCode == 6'h03 || (OpCode == 6'h0 && Funct == 6'h09)) ? 2'd2
    : 2'd0;             // addi, addiu, lw, lui, slti, sltiu, andi? 1: jal, jalr? 2:0
    assign MemRead = (OpCode == 6'h23);
    assign MemWrite = (OpCode == 6'h2b);
    assign MemtoReg = (OpCode == 6'h23)? 2'd1
    : (OpCode == 6'h03 || (OpCode == 6'h0 && Funct == 6'h09)) ? 2'd2
    : 2'd0;             //lw? 1: jal, jalr? 2:0
    assign ALUSrc1 = (OpCode != 6'h0 && OpCode != 6'h04);
                        // !R-type && !beq? 1:0
    assign ALUSrc2 = (OpCode == 6'h0) && (Funct == 6'h0 || Funct == 6'h02 || Funct == 6'h03);
                        // shift operation? 1:0
    assign ExtOp = ~(OpCode == 6'h0c);
                        // !andi
    assign LuOp = (OpCode == 6'h0f);
                        // lui
endmodule