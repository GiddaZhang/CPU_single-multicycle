module ALU(in1, in2, ALUCtrl, Sign, out, zero);
	input [31:0] in1, in2;
	input [4:0] ALUCtrl;
	input Sign;
	output reg [31:0] out;
	output zero;
	
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

    wire [31:0] in1_minus_in2;
    assign in1_minus_in2 = in1 - in2;
    always @ (*) begin
        case (ALUCtrl)
            And: out <= in1 & in2;
            Or:  out <= in1 | in2;
            Add: out <= in1 + in2;
            Sub: out <= in1 - in2;
            Slt: out <= (Sign)? (in1_minus_in2[31]) : (in1 < in2);
            Nor: out <= ~(in1 | in2);
            Xor: out <= in1 ^ in2;
            Sll: out <= in2 << in1[4:0];
            Srx: out <= (Sign == 1'b0)? (in2 >> in1[4:0]) : ({{32{in2[31]}}, in2} >> in1[4:0]);
            Lui: out <= in2;      // in2 is the extended immediate
            default: out <= 32'd0;
        endcase
    end

    assign zero = (out == 5'd0);
	
endmodule