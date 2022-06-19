
module test_cpu();
	
	reg reset;
	reg clk;
	wire [15:0] a0, v0, sp, ra;
	
	CPU cpu1(reset, clk, a0, v0, sp, ra);
	
	initial begin
		reset = 1;
		clk = 1;
		#100 reset = 0;
	end
	
	always #50 clk = ~clk;
		
endmodule
