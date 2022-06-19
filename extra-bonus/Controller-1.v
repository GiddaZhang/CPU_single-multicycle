`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng, Shang Yang, Jida Zhang
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: Controller_1
// Project Name: Multi-cycle-cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.10 - Merge States
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Controller_1(reset, clk, OpCode, Funct, 
                PCWrite, PCWriteCond, IorD, MemWrite, MemRead,
                IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                ALUSrcA, ALUSrcB, ALUOp, PCSource);
    //Input Clock Signals
    input reset;
    input clk;
    //Input Signals
    input  [5:0] OpCode;
    input  [5:0] Funct;
    //Output Control Signals
    output reg PCWrite;
    output reg PCWriteCond;
    output reg [1:0] IorD;      // Inst(0) or Data(1)
    output reg MemWrite;
    output reg MemRead;
    output reg IRWrite;
    output reg [2:0] MemtoReg;  // 00:MEM; 01:ALUOut; 10:jal; 11:ALUResult 100:Mem_data
    output reg [1:0] RegDst;    // 00:I-type,01:R-type,rd; 10: jal
    output reg RegWrite;
    output reg ExtOp;
    output reg LuiOp;
    output reg [1:0] ALUSrcA;   // 00:PC; 01:RegA; 10:ImmExt for shift
    output reg [1:0] ALUSrcB;   // 00:RegB; 01:4; 11:sign-extended(IR[15:0] << 2
    output reg [3:0] ALUOp;
    output reg [1:0] PCSource;  // 00:ALU.Result; 01:ALUOut; 10:Inst[25:0] << 2

    reg [2:0] state; //current state
    reg [2:0] next_state; //next_state
    parameter sIF = 3'b0, sID = 3'b1; 
    
    parameter ADD = 4'b0000;
    parameter BEQ = 4'b0001;
    parameter R_TYPE = 4'b0010;
    parameter ADDIU = 4'd3;
    parameter ANDI = 4'd4;
    parameter SLTI = 4'd5;
    parameter SLTIU = 4'd6;

    always @(posedge reset or posedge clk) 
    begin
        if (reset) 
            begin
                state <= 3'b0;
                next_state <=3'b0;
                PCWrite <= 1'b0;
                PCWriteCond <= 1'b0;
                IorD <= 1'b0;
                MemWrite <= 1'b0;
                MemRead <= 1'b0;
                IRWrite <= 1'b0;
                MemtoReg <= 2'b00;
                RegDst <= 2'b0;
                RegWrite <= 1'b0;
                ExtOp <= 1'b0;
                LuiOp <= 1'b0;
                ALUSrcA <= 2'b0;
                ALUSrcB <= 2'b0;
                PCSource <= 2'b0;
            end
        else
        begin
            if (next_state == sIF) // sIF = 3'b0
                begin
                    state <= next_state;
                    next_state <= next_state + 3'b1;
                    
                    MemRead <= 1'b1;
                    IRWrite <= 1'b1;
                    PCWrite <= 1'b1;
                    PCSource <= 2'b00;
                    ALUSrcA <= 2'b00;
                    IorD <= 1'b0;
                    ALUSrcB <= 2'b01;
        
                    PCWriteCond <= 1'b0;
                    MemWrite <= 1'b0;
                    MemtoReg <= 2'b00;
                    RegDst <= 2'b0;
                    RegWrite <= 1'b0;
                    ExtOp <= 1'b0;
                    LuiOp <= 1'b0;

                    ALUOp <= ADD;       // ALUOut = PC+4
                end
                
            else if (next_state == sID) // sIF = 3'b1
                begin
                    state <= next_state;
                    next_state <= next_state + 3'b1;
                    ALUSrcA <= 2'b00;
                    ALUSrcB <= 2'b11;    
                    ExtOp <= 1'b1;
                    
                    PCWrite <= 1'b0;
                    PCWriteCond <= 1'b0;
                    IorD <= 1'b0;
                    MemWrite <= 1'b0;
                    MemRead <= 1'b0;
                    IRWrite <= 1'b0;
                    MemtoReg <= 2'b00;
                    RegDst <= 2'b0;
                    RegWrite <= 1'b0;
                    LuiOp <= 1'b0;
                    PCSource <= 2'b0;

                    ALUOp <= ADD;     // ALUOut = PC + (sign-extended(IR[15:0] << 2)
                end
            else if (next_state == 3'd2) 
                begin
                    state <= next_state;
                    case(OpCode)
                        6'h00:        // R-Type
                            begin
                                // Sll, Srl, Sra? ImmExt : RegA
                                ALUSrcA <= (Funct==6'h00 || Funct==6'h02 || Funct==6'h03 ) ? 2'b10 : 2'b01; 
                                ALUSrcB <= 2'b00;     // RegB              
                                case(Funct)
                                    6'h08:  // jr      
                                        begin
                                            PCSource <= 2'b00;
                                            PCWrite  <= 1'b1;
                                            next_state <= sIF;

                                            ALUOp <= ADD;
                                        end
                                    6'h09:  // jalr        
                                        begin
                                            PCSource <= 2'b00;
                                            PCWrite  <= 1'b1;
                                            next_state <= sIF;
                                            
                                            RegDst <= 2'b01;
                                            MemtoReg <= 2'b10;
                                            RegWrite <= 1'b1;

                                            ALUOp <= ADD;
                                        end

                                    // MERGE: R-type except jr & jalr
                                    default:
                                        begin
                                            // next_state <= next_state + 3'b1;
                                            next_state <= sIF;
                                            
                                            RegWrite <= 1'b1;
                                            RegDst <= 2'b01;
                                            // MemtoReg <= 2'b01;
                                            MemtoReg <= 2'b11;

                                            ALUOp <= R_TYPE;
                                        end
                                endcase
                            end
                        6'h23,6'h2b,6'h0f,6'h08,6'h09,6'h0c,6'h0b,6'h0a:    
                        // lw, sw, lui, addi, addiu, andi, slti, sltiu
                            begin
                                ALUSrcA <= 2'b01;                   // RegA
                                ALUSrcB <= 2'b10;                   // ImmExt
                                ExtOp <= ((OpCode==6'h0c)? 0 : 1);  // andi unsigned ext 
                                LuiOp <= ((OpCode==6'h0f)? 1 : 0);  // lui
                                // next_state <= next_state + 3'b1;

                                if (OpCode == 6'h23 || OpCode == 6'h2b || OpCode == 6'h08)
                                    ALUOp <= ADD;           // lw, sw, addi
                                else if (OpCode == 6'h09) 
                                    ALUOp <= ADDIU;         // addiu
                                else if (OpCode == 6'h0c) 
                                    ALUOp <= ANDI;          // andi
                                else if (OpCode == 6'h0a) 
                                    ALUOp <= SLTI;          // slti
                                else if (OpCode == 6'h0b) 
                                    ALUOp <= SLTIU;         // sltiu
                                else
                                    ALUOp <= ADD;
                                
                                case(OpCode) 
                                    6'h2b:  // sw
                                        next_state <= next_state + 3'b1;
                                    6'h23:  // lw
                                        next_state <= next_state + 3'b1;
                                    
                                    // MERGE: I-type except sw & lw
                                    default: begin
                                        next_state <= sIF;

                                        RegWrite <= 1'b1;
                                        RegDst <= 2'b00;
                                        // MemtoReg <= 2'b01;
                                        MemtoReg <= 2'b11;
                                    end
                                endcase
                            end
                        6'h04: // beq
                            begin
                                PCWriteCond <= 1'b1;
                                ALUSrcA <= 2'b01;   // RegA
                                ALUSrcB <= 2'b00;   // RegB
                                PCSource <= 2'b01;  // ALUOut
                                next_state <= sIF;

                                ALUOp <= BEQ;
                            end
                        6'h02: // j
                            begin
                                PCWrite <= 1'b1;
                                PCSource <= 2'b10;
                                next_state <= sIF;

                                ALUOp <= ALUOp;
                            end
                        6'h03: // jal
                            begin
                                PCWrite <= 1'b1;
                                PCSource <= 2'b10;
                                                               
                                RegDst <= 2'b10;   
                                MemtoReg <= 2'b10;
                                RegWrite <= 1'b1;
                                
                                next_state <= sIF;

                                ALUOp <= ALUOp;
                            end 
                        default: 
                            begin
                                next_state <= sIF;

                                ALUOp <= ALUOp;
                            end
                    endcase
                end
            else if (next_state == 3'd3) 
                begin
                    state <= next_state;
                    case(OpCode)

                        // BE MERGED
                        // 6'h00:  // R-Type
                        //     begin
                        //         RegWrite <= 1'b1;
                        //         RegDst <= 2'b01;
                        //         MemtoReg <= 2'b01;
                        //         next_state <= sIF;

                        //         ALUOp <= R_TYPE;
                        //     end
                        6'h2b:  // sw
                            begin
                                MemWrite <= 1'b1;
                                IorD <= 1'b1;
                                next_state <= sIF;

                                ALUOp <= ALUOp;
                            end
                        // BE MERGED
                        // 6'h08,6'h09,6'h0c,6'h0b,6'h0a,6'h0f:    
                        // // addi, addiu, andi, slti, sltiu, lui  
                        //     begin
                        //         RegWrite <= 1'b1;
                        //         RegDst <= 2'b00;
                        //         MemtoReg <= 2'b01;
                        //         next_state <= sIF;

                        //         ALUOp <= ALUOp;
                        //     end
                        6'h23:  // lw
                            begin
                                MemRead <= 1'b1;
                                IorD <= 1'b1;
                                IRWrite <=1'b0;
                                
                                RegWrite <= 1'b1;
                                RegDst <= 2'b00;
                                MemtoReg <= 3'b100;

                                next_state <= sIF; 
                                ALUOp <= ALUOp;
                            end
                        default: 
                            begin
                                next_state <= sIF;

                                ALUOp <= ALUOp;
                            end
                    endcase
        
                end
            // BE MERGED: the fifth cycle of lw does not exist
            // else if (next_state == 3'd4) 
            //     begin
            //         state <= next_state;
            //         case(OpCode)
            //             6'h23: 
            //                 begin
            //                     RegWrite <= 1'b1;
            //                     RegDst <= 2'b00;
            //                     MemtoReg <= 2'b00;
            //                     next_state <= sIF;

            //                     ALUOp <= ALUOp;
            //                 end
            //             default: 
            //                 begin
            //                     next_state <= sIF;

            //                     ALUOp <= ALUOp;
            //                 end
            //         endcase
            //      end
         end
    end

endmodule