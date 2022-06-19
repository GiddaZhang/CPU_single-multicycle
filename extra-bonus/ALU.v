`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: ALU
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


module ALU(ALUConf, Sign, In1, In2, Zero, Result);
    // Control Signals
    input [4:0] ALUConf;
    input Sign;
    // Input Data Signals
    input [31:0] In1;
    input [31:0] In2;
    // Output 
    output Zero;
    output reg [31:0] Result;

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

    wire [31:0] In1_minus_In2;
    assign In1_minus_In2 = In1 - In2;
    
    always @ (*) begin
        case (ALUConf)
            And: Result <= In1 & In2;
            Or:  Result <= In1 | In2;
            Add: Result <= In1 + In2;
            Sub: Result <= In1 - In2;
            Slt: Result <= (Sign)? (In1_minus_In2[31]) : (In1 < In2);
            Nor: Result <= ~ (In1 | In2);
            Xor: Result <= In1 ^ In2;
            Sll: Result <= In2 << In1[4:0];
            Srx: Result <= (Sign == 1'b0)?  (In2 >> In1[4:0]) : ({{32{In2[31]}}, In2} >> In1[4:0]);
            Lui: Result <= In2;      // In2 is the extended immediate
            default: 
                 Result <= 32'd0;
        endcase
    end

    assign Zero = (Result == 32'd0);

endmodule
