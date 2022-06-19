module CPU(reset, clk, a0, v0, sp, ra);
	input reset, clk;
	output [15:0] a0, v0, sp, ra;
    assign a0 = xRegisterFile.RF_data[4];
    assign v0 = xRegisterFile.RF_data[2];
    assign sp = xRegisterFile.RF_data[29];
    assign ra = xRegisterFile.RF_data[31];

    // Instruction fetch
    reg  [31:0] PC;
    wire [31:0] Instruction;
    InstructionMemory_2 xInstructionMemory(.Address(PC), .Instruction(Instruction));

    // Decode the instruction
    wire [5:0] OpCode, Funct;
    wire [4:0] rs, rt, rd, shamt;
    wire [15:0] immediate;
    wire [25:0] jumpAddress;
    assign OpCode = Instruction[31:26];
    assign rs = Instruction[25:21];
    assign rt = Instruction[20:16];
    assign rd = Instruction[15:11];
    assign shamt = Instruction[10:6];
    assign Funct = Instruction[5:0];
    assign immediate = Instruction[15:0];
    assign jumpAddress = Instruction[25:0];

    // Generate control signal
    wire [1:0] PCSrc, RegDst, MemtoReg;
	wire Branch, RegWrite, MemRead, MemWrite, ALUSrc1, ALUSrc2, ExtOp, LuOp;
    Control xControl(.OpCode(OpCode), .Funct(Funct), .PCSrc(PCSrc), .Branch(Branch), 
                    .RegWrite(RegWrite), .RegDst(RegDst), .MemRead(MemRead), 
                    .MemWrite(MemWrite), .MemtoReg(MemtoReg), .ALUSrc1(ALUSrc1),
                    .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp));
    
    // Generate control signal for ALU
    wire Sign;
    wire [4:0] ALUCtrl;
    ALUControl xALUControl(.OpCode(OpCode), .Funct(Funct), .Sign(Sign), .ALUCtrl(ALUCtrl));

    // Get data from RF
    wire [4:0] Read_register1, Read_register2, Write_register;
	wire [31:0] Write_data_reg;
	wire [31:0] Read_data1_reg, Read_data2_reg;
    assign Read_register1 = rs;
    assign Read_register2 = rt;
    // MUX
    assign Write_register = RegDst[1]? 5'd31: (RegDst[0]? rt : rd);
    RegisterFile xRegisterFile(reset, clk, RegWrite, Read_register1, Read_register2, 
                              Write_register, Write_data_reg, Read_data1_reg, Read_data2_reg);

    // Determine the input of ALU
    wire [31:0] in1, in2;
    wire [31:0] immediate_ext;
    // MUX * 2
    assign immediate_ext = LuOp? {immediate, 16'b0} : {ExtOp? {16{immediate[15]}} : 16'b0, immediate};
    // MUX
    assign in1 = ALUSrc2? shamt : Read_data1_reg;
    // MUX
    assign in2 = ALUSrc1? immediate_ext : Read_data2_reg;

    // ALU operation
    wire [31:0] out;
    wire zero;
    ALU xALU(.in1(in1), .in2(in2), .ALUCtrl(ALUCtrl), .Sign(Sign), .out(out), .zero(zero));

    // Memory
    wire [31:0] Address_mem, Read_data_mem, Write_data_mem;
    assign Address_mem = out;
    assign Write_data_mem = Read_data2_reg;
    DataMemory xDataMemory(reset, clk, Address_mem, Write_data_mem, Read_data_mem, MemRead, MemWrite);

    // Register write back
    // MUX * 2
    assign Write_data_reg = MemtoReg[1]? (PC + 3'd4) : (MemtoReg[0]? Read_data_mem : out);
    
    // Switch PC 
    wire [31:0] PC_plus_4 = PC + 3'd4; 
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            PC <= 32'd0;
        end
        else begin
            case(PCSrc) 
                2'd3: PC <= Read_data1_reg;     // jr, jalr
                2'd2: PC <= {PC_plus_4[31:28], jumpAddress, 2'b00}; //j, jal
                2'd1: PC <= PC_plus_4 + ((Branch && zero)? immediate_ext << 2'd2 : 1'b0);
                2'd0: PC <= PC_plus_4;
            endcase
        end
    end
    
endmodule
	