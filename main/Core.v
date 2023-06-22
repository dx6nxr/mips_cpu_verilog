module MIPScore(
	input clk,
	input reset,
	// Connected to instruction memory
	output [31:0] pc,
	input  [31:0] instr,
	// Connected to data memory
	output        memwrite,
	output [31:0] aluout, writedata,
	input  [31:0] readdata
);
	wire       memtoreg, alusrcbimm, shift16left, zeroextend, slt, dojump, dobranch, zero;
	wire       regwrite;
	wire [4:0] destreg;
	wire [2:0] alucontrol;

	Decoder decoder(instr, zero, memtoreg, memwrite,
					dobranch, alusrcbimm, slt, shift16left, zeroextend, destreg,
					regwrite, dojal, dojr, dojump, alucontrol);
	Datapath dp(clk, reset, memtoreg, dobranch,
				alusrcbimm, slt, shift16left, zeroextend, destreg, regwrite, dojal, dojr, dojump,
				alucontrol,
				zero, pc, instr,
				aluout, writedata, readdata);
endmodule

