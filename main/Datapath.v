module Datapath(
	input         clk, reset,
	input         memtoreg,
	input         dobranch,
	input         alusrcbimm,
	input 	      slt,
	input 	      shift16left,
	input  [4:0]  destreg,
	input         regwrite,
	input 	      dojal,
	inout         dojr,
	input         jump,
	input  [2:0]  alucontrol,
	output        zero,
	output [31:0] pc,
	input  [31:0] instr,
	output [31:0] aluout,
	output [31:0] writedata,
	input  [31:0] readdata
);
	wire [31:0] pc;
	wire [31:0] signimm;
	wire [31:0] srca, srcb, srcbimm, pcjal;
	wire [31:0] result;
	wire [63:0]	hilo, hiloinp;

	// Fetch: Pass PC to instruction memory and update PC
	ProgramCounter pcenv(clk, reset, dobranch, signimm, jump, instr[25:0], dojr, pcjal, pc);

	// Execute:
	// (a) Select operand
	SignExtension se(instr[15:0], signimm);
	assign srcbimm = alusrcbimm ? signimm :
	shift16left ? {instr[15:0], 16'b0} : srcb;
	// (b) Perform computation in the ALU
	ArithmeticLogicUnit alu(srca, srcbimm, alucontrol, aluout, zero, hilo, hiloinp);
	Slt sltt(srca, srcbimm, zero);
	// (c) Select the correct result
	assign result = slt ? zero : memtoreg ? readdata : aluout;

	// Memory: Data word that is transferred to the data memory for (possible) storage
	assign writedata = srcb;

	// Write-Back: Provide operands and write back the result
	RegisterFile gpr(pc, clk, regwrite, dojal, instr[25:21], instr[20:16],
				   destreg, result, srca, srcb, pcjal, hiloinp, hilo);
endmodule

module ProgramCounter(
	input         clk,
	input         reset,
	input         dobranch,
	input  [31:0] branchoffset,
	input         dojump,
	input  [25:0] jumptarget,
	input         dojr, // 1 if yes, 0 if no
	input  [31:0] pcjr,
	output [31:0] progcounter
);
	reg  [31:0] pc;

	wire [31:0] incpc, branchpc, nextpc;

	// Increment program counter by 4 (word aligned)
	Adder pcinc(.a(pc), .b(32'b100), .cin(1'b0), .y(incpc));
	// Calculate possible (PC-relative) branch target
	Adder pcbranch(.a(incpc), .b({branchoffset[29:0], 2'b00}), .cin(1'b0), .y(branchpc));
	// Select the next value of the program counter

	//add dojal and dojr support
	// TODO

	assign nextpc = dojr ? pcjr :
					dojump   ? {incpc[31:28], jumptarget, 2'b00} :
					dobranch ? branchpc :
							   incpc;
							   //add dojal here

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
	input         we3, //regwrite
	input         dojal,
	input  [4:0]  ra1, ra2, wa3, // isntr, instr, destreg
	input  [31:0] wd3, // result
	output [31:0] rd1, rd2, //srca, srcb
	output [31:0] pcjal, // outputs register 31
	input [63:0] hiloinp, // inputs hilo
	output [63:0] hilo // outputs hilo
);
	reg [31:0] registers[31:0];
	reg [63:0] hiloreg;
	
	always @(*) begin
		hiloreg <= hiloinp;
	end

	always @(posedge clk)
		if (we3 == 1) begin
			registers[wa3] <= wd3;
		end
		else if (dojal == 1) begin
			registers[31] <= pc + 4;
		end

	assign rd1 = (ra1 != 0) ? registers[ra1] : 0;
	assign rd2 = (ra2 != 0) ? registers[ra2] : 0;
	assign pcjal = registers[31];
	assign hilo = hiloreg;
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
	input  [2:0]  alucontrol,
	output [31:0] result,
	output        zero,
	input [63:0] hilo,
	output reg [63:0] hiloout
);
	reg [31:0] RES;

	assign zero = (RES == 0);
	assign result = RES;
	always @(*) begin
		case (alucontrol)
			3'b000: RES = a & b;
			3'b001: RES = a | b;
			3'b010: RES = a + b;
			3'b110: RES = a - b;
			3'b100: RES = hilo[63:32]; //mfhi
			3'b101: RES = hilo[31:0]; //mflo
			3'b011: hiloout = a * b; // mulu
			3'b111: hiloout = {(a % b),(a / b)}; // divu
			default: RES = 0;
		endcase
	end
endmodule

module Slt(
	input  [31:0] a, b,
	output        zero
);
	assign zero = (a < b) ? 0 : 1;
endmodule