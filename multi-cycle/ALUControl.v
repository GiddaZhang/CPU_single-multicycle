`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: ALUControl
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


module ALUControl(ALUOp, Funct, ALUConf, Sign);
	//Control Signals
	input [3:0] ALUOp;
	//Inst. Signals
	input [5:0] Funct;
	//Output Control Signals
	output reg [4:0] ALUConf;
	output Sign;

    parameter BEQ = 4'b0001;
    parameter R_TYPE = 4'b0010;
    parameter ADDIU = 4'd3;
    parameter ANDI = 4'd4;
    parameter SLTI = 4'd5;
    parameter SLTIU = 4'd6;

	parameter And = 5'd0;
    parameter Or  = 5'd1;
    parameter Add = 5'd2;
    parameter Sub = 5'd3;
    parameter Slt = 5'd4;
    parameter Nor = 5'd5;
    parameter Xor = 5'd6;
    parameter Sll = 5'd7;
    parameter Srx = 5'd8;
    parameter Lui = 5'd9;

    always @(*) begin
        case (ALUOp)
            4'b0000:
                ALUConf <= Add;
            BEQ:
                ALUConf <= Sub;
            R_TYPE:
            begin
                // R-Type instructions
                if(Funct == 6'h20) begin
                    ALUConf <= Add;    // add 
                end
                else if(Funct == 6'h21) begin
                    ALUConf <= Add;    // addu
                end
                else if(Funct == 6'h22) begin
                    ALUConf <= Sub;    // sub 
                end
                else if(Funct == 6'h23) begin
                    ALUConf <= Sub;    // subu
                end
                else if(Funct == 6'h24) begin
                    ALUConf <= And;    // and
                end 
                else if(Funct == 6'h25) begin
                    ALUConf <= Or;    // or
                end 
                else if(Funct == 6'h26) begin
                    ALUConf <= Xor;    // xor
                end 
                else if(Funct == 6'h27) begin
                    ALUConf <= Nor;    // nor
                end 
                else if(Funct == 6'h0) begin
                    ALUConf <= Sll;    // sll
                end 
                else if(Funct == 6'h02) begin
                    ALUConf <= Srx;    // srl
                end                
                else if(Funct == 6'h03) begin
                    ALUConf <= Srx;    // sra 
                end 
                else if(Funct == 6'h2a) begin
                    ALUConf <= Slt;    // slt 
                end 
                else if(Funct == 6'h2b) begin
                    ALUConf <= Slt;    // sltu
                end
            end
            ADDIU:
                ALUConf <= Add;
            ANDI:
                ALUConf <= And;
            SLTI:
                ALUConf <= Slt;
            SLTIU:
                ALUConf <= Slt;
            default: 
                ALUConf <= Add;
        endcase
    end

    assign Sign = (ALUOp == R_TYPE && Funct == 6'h03) ||
                  (ALUOp == R_TYPE && Funct == 6'h2a) ||
                  (ALUOp == SLTI);
    // Sign = 1 when sra or slt or slti
endmodule
