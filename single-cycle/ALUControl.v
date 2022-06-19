
module ALUControl(OpCode, Funct, ALUCtrl, Sign);
	input [5:0] OpCode;
	input [5:0] Funct;
	output reg [4:0] ALUCtrl;
	output reg Sign;
	
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
        
        case (OpCode)

            6'h23: begin
                ALUCtrl <= Add;     // lw
                Sign <= 1'b0; 
            end
            6'h2b: begin
                ALUCtrl <= Add;     // sw
                Sign <= 1'b0; 
            end
            6'h0f: begin
                ALUCtrl <= Lui;    // lui
                Sign <= 1'b0; 
            end
            6'h08: begin
                ALUCtrl <= Add;     // addi
                Sign <= 1'b1; 
            end
            6'h09: begin
                ALUCtrl <= Add;     // addiu
                Sign <= 1'b0; 
            end
            6'h0c: begin
                ALUCtrl <= And;    // andi
                Sign <= 1'b0; 
            end
            6'h0a: begin
                ALUCtrl <= Slt;    // slti
                Sign <= 1'b1; 
            end
            6'h0b: begin
                ALUCtrl <= Slt;    // sltiu
                Sign <= 1'b0; 
            end
            6'h04: begin
                ALUCtrl <= Sub;    // beq
                Sign <= 1'b0; 
            end
            6'h02: begin
                // j does not depend on ALU
            end
            6'h03: begin
                // jal does not depend on ALU
            end
            6'h0: begin

                // R-Type instructions
                if(Funct == 6'h20) begin
                    ALUCtrl <= Add;    // add
                    Sign <= 1'b1; 
                end
                else if(Funct == 6'h21) begin
                    ALUCtrl <= Add;    // addu
                    Sign <= 1'b0; 
                end
                else if(Funct == 6'h22) begin
                    ALUCtrl <= Sub;    // sub
                    Sign <= 1'b1; 
                end
                else if(Funct == 6'h23) begin
                    ALUCtrl <= Sub;    // subu
                    Sign <= 1'b0; 
                end
                else if(Funct == 6'h24) begin
                    ALUCtrl <= And;    // and
                    Sign <= 1'b0; 
                end 
                else if(Funct == 6'h25) begin
                    ALUCtrl <= Or;    // or
                    Sign <= 1'b0; 
                end 
                else if(Funct == 6'h26) begin
                    ALUCtrl <= Xor;    // xor
                    Sign <= 1'b0; 
                end 
                else if(Funct == 6'h27) begin
                    ALUCtrl <= Nor;    // nor
                    Sign <= 1'b0; 
                end 
                else if(Funct == 6'h0) begin
                    ALUCtrl <= Sll;    // sll
                    Sign <= 1'b0; 
                end 
                else if(Funct == 6'h02) begin
                    ALUCtrl <= Srx;    // srl
                    Sign <= 1'b0; 
                end                
                else if(Funct == 6'h03) begin
                    ALUCtrl <= Srx;    // sra
                    Sign <= 1'b1; 
                end 
                else if(Funct == 6'h2a) begin
                    ALUCtrl <= Slt;    // slt
                    Sign <= 1'b1; 
                end 
                else if(Funct == 6'h2b) begin
                    ALUCtrl <= Slt;    // sltu
                    Sign <= 1'b0; 
                end 
                else if(Funct == 6'h08) begin
                    // jr does not depend on ALU
                end 
                else if(Funct == 6'h09) begin
                    // jalr does not depend on ALU
                end

            end
        endcase

    end

endmodule
