module Decoder(
	input     [31:0] instr,      // Instruction word
	input            zero,       // Does the current operation in the datapath return 0 as result?
	output reg       memtoreg,   // Use the loaded word instead of the ALU result as result
	output reg       memwrite,   // Write to the data memory
	output reg       dobranch,   // Perform a relative jump
	output reg       alusrcbimm, // Use the immediate value as second operand
	output reg       slt,		// Is the current instruction a set-less-than?
	output reg       shift16left, // shift the immediate value 16 bits to the left
	output reg       zeroextend, // shift the immediate value 16 bits to the right
	output reg [4:0] destreg,    // Number of the target register to (possibly) be written
	output reg       regwrite,   // Write to the target register
	output reg       dojal,   	 // save the return address in $ra
	output reg       dojr,   	 // jump to the return address in $ra
	output reg       dojump,     // Perform an absolute jump
	output reg [2:0] alucontrol  // ALU control bits
);
	// Extract the primary and secondary opcode
	wire [5:0] op = instr[31:26];
	wire [5:0] funct = instr[5:0];

	always @*
	begin
		case (op)
			6'b000000: // R-type instruction
			if (funct == 6'b101011) // sltu
					begin
						regwrite = 1;
						dojal = 0;
						dojr = 0;
						destreg = instr[15:11];
						alusrcbimm = 0;
						slt = 1;
						shift16left = 0;
						zeroextend = 0;
						dobranch = 0;
						memwrite = 0;
						memtoreg = 0;
						dojump = 0;
						alucontrol = 3'bxxx; //default (undefined) behavior of ALU
					end
				else 
				if (funct == 6'b001000) // jr
				begin
					regwrite = 0;
					dojal = 0;
					dojr = 1;
					destreg = 5'bx;
					alusrcbimm = 0;
					slt = 0;
					shift16left = 0;
					zeroextend = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'bxxx; //default (undefined) behavior of ALU
				end
				else 
				begin
						regwrite = 1;
						dojal = 0;
						dojr = 0;
						destreg = instr[15:11];
						alusrcbimm = 0;
						slt = 0;
						shift16left = 0;
						zeroextend = 0;
						dobranch = 0;
						memwrite = 0;
						memtoreg = 0;
						dojump = 0;
						case (funct)
							6'b100001: alucontrol = 3'b010; // addition unsigned
							6'b100011: alucontrol = 3'b110; // subtraction unsigned
							6'b100100: alucontrol = 3'b000; // and
							6'b100101: alucontrol = 3'b001; // or
							6'b011011: alucontrol = 3'b111; // divu
							6'b010000: alucontrol = 3'b100; // mfhi
							6'b010010: alucontrol = 3'b101; // mflo
							6'b011001: alucontrol = 4'b011; // mulu
							default:   alucontrol = 3'bxxx; // undefined
						endcase
				end
			6'b100011, // Load data word from memory
			6'b101011: // Store data word
				begin
					regwrite = ~op[3];
					dojal = 0;
					dojr = 0;
					destreg = instr[20:16];
					alusrcbimm = 1;
					slt = 0;
					shift16left = 0;
					zeroextend = 0;
					dobranch = 0;
					memwrite = op[3];
					memtoreg = 1;
					dojump = 0;
					alucontrol = 3'b010;// TODO // Effective address: Base register + offset  example: 4($a0)
				end
			6'b000100: // Branch Equal
				begin
					regwrite = 0;
					dojal = 0;
					dojr = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					slt = 0;
					shift16left = 0;
					zeroextend = 0;
					dobranch = zero; // Equality test
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b110; // Subtraction
				end
			6'b001001: // Addition immediate unsigned
				begin
					regwrite = 1;
					dojal = 0;
					dojr = 0;
					destreg = instr[20:16];
					alusrcbimm = 1;
					slt = 0;
					shift16left = 0;
					zeroextend = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b010; // Addition
				end
			6'b000010: // Jump immediate
				begin
					regwrite = 0;
					dojal = 0;
					dojr = 0;
					destreg = 5'bx;
					alusrcbimm = 1;
					slt = 0;
					shift16left = 0;
					zeroextend = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					alucontrol = 3'bxxx; //default (undefined) behavior of ALU
				end
			6'b001101: //ori 001101
				begin
					regwrite = 1;
					dojal = 0;
					dojr = 0;
					destreg = instr[20:16];
					alusrcbimm = 0;
					slt = 0;
					shift16left = 0;
					zeroextend = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b001;
				end
			6'b001111: //lui 001111
				begin
					regwrite = 1;
					dojal = 0;
					dojr = 0;
					destreg = instr[20:16];
					alusrcbimm = 0;
					slt = 0;
					shift16left = 1;
					zeroextend = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'b010;
				end
				//implement the bltz instruction with the opcode 000001
			6'b000001: //bltz 000001
				begin
					regwrite = 0;
					dojal = 0;
					dojr = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					slt = 1;
					shift16left = 0;
					zeroextend = 0;
					dobranch = !zero;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 3'bxxx; // Comparison
				end
			6'b000011: //jal 000011
				begin
					regwrite = 0;
					dojal = 1;
					dojr = 0;
					destreg = 5'bxxxxx;
					alusrcbimm = 1;
					slt = 0;
					shift16left = 0;
					zeroextend = 0;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					alucontrol = 3'bx; // Default
				end
			default: // Default case
				begin
					regwrite = 1'bx;
					dojal = 1'bx;
					dojr = 1'bx;
					destreg = 5'bx;
					alusrcbimm = 1'bx;
					slt = 1'bx;
					shift16left = 1'bx;
					zeroextend = 1'bx;
					dobranch = 1'bx;
					memwrite = 1'bx;
					memtoreg = 1'bx;
					dojump = 1'bx;
					alucontrol = 3'bx; //default (undefined) behavior of ALU
				end
		endcase
	end
endmodule

