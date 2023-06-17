module Datapath(
	input         clk, reset,
	input         memtoreg,
	input         dobranch,
	input         alusrcbimm,
	input  [4:0]  destreg,
	input  [1:0]  regwrite,
	input         jump,
	input  [3:0]  alucontrol,
	output        zero,
	output [31:0] pc,
	input  [31:0] instr,
	output [31:0] aluout,
	output [31:0] writedata,
	input  [31:0] readdata
);
	wire [31:0] pc;
	wire [31:0] signimm;
	wire [31:0] srca, srcb, srcbimm;
	wire [31:0] result;

	// Fetch: Pass PC to instruction memory and update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump, instr[25:0], pc);

	// Execute:
	// (a) Select operand
	SignExtension se(instr[15:0], signimm);
	assign srcbimm = alusrcbimm ? signimm : srcb;
	// (b) Perform computation in the ALU
	ArithmeticLogicUnit alu(srca, srcbimm, alucontrol, aluout, zero);
	// (c) Select the correct result
	assign result = memtoreg ? readdata : aluout;

	// Memory: Data word that is transferred to the data memory for (possible) storage
	assign writedata = srcb;

	// Write-Back: Provide operands and write back the result
	RegisterFile gpr(pc, clk, regwrite, instr[25:21], instr[20:16],
				   destreg, result, srca, srcb);
endmodule

module ProgramCounter(
	input         clk,
	input         reset,
	input         dobranch,
	input  [31:0] branchoffset,
	input         dojump,
	input  [25:0] jumptarget,
	output [31:0] progcounter
);
	reg  [31:0] pc;
	wire [31:0] incpc, branchpc, nextpc;

	// Increment program counter by 4 (word aligned)
	Adder pcinc(.a(pc), .b(32'b100), .cin(1'b0), .y(incpc));
	// Calculate possible (PC-relative) branch target
	Adder pcbranch(.a(incpc), .b({branchoffset[29:0], 2'b00}), .cin(1'b0), .y(branchpc));
	// Select the next value of the program counter
	assign nextpc = dojump   ? {incpc[31:28], jumptarget, 2'b00} :
					dobranch ? branchpc :
							   incpc;

	// The program counter memory element
	always @(posedge clk)
	begin
		if (reset) begin // Initialize with address 0x00400000
			pc <= 'h00400000;
		end else begin
			pc <= nextpc;
		end
	end

	// Output
	assign progcounter = pc;

endmodule

module RegisterFile(
	input [31:0]  pc,
	input         clk,
	input  [1:0]  we3, //regwrite
	input  [4:0]  ra1, ra2, wa3, // isntr, instr, destreg
	input  [31:0] wd3, // result
	output [31:0] rd1, rd2 //srca, srcb
);
	reg [31:0] pcreg;
	reg [31:0] registers[31:0];
	always @(*)
		pcreg = pc + 4;
	
	always @(posedge clk)
		if (we3 == 1) begin
			registers[wa3] <= wd3;
		end
		else if(we3 == 2) begin
			registers[wa3] <= pcreg;
		end

	assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
	assign rd2 = (ra2 != 0) ? registers[ra2] : 0;
endmodule

module Adder(
	input  [31:0] a, b,
	input         cin,
	output [31:0] y,
	output        cout
);
	assign {cout, y} = a + b + cin;
endmodule

module SignExtension(
	input  [15:0] a,
	output [31:0] y
);
	assign y = {{16{a[15]}}, a};
endmodule

module ArithmeticLogicUnit(
	input  [31:0] a, b,
	input  [3:0]  alucontrol,
	output [31:0] result,
	output        zero
);
	reg [31:0] RES;
	reg [63:0] hilo;

	assign zero = (RES == 0);
	assign result = RES;
	always @(*)
	case (alucontrol)
		4'b0000: RES = a & b;
		4'b0001: RES = a | b;
		4'b0010: RES = a + b;
		4'b0110: RES = a - b;
		4'b1000: RES = {b, 16'b0}; // lui
		4'b1110: RES = a < b ? 1 : 0;
		4'b1100: RES = hilo[63:32]; //mfhi
		4'b1010: RES = hilo[31:0]; //mflo
		4'b0111: hilo = a * b; // mulu
		default: RES = 0;
	endcase
endmodule