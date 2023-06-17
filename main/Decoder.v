module Decoder(
	input     [31:0] instr,      // Instruction word
	input            zero,       // Does the current operation in the datapath return 0 as result?
	output reg       memtoreg,   // Use the loaded word instead of the ALU result as result
	output reg       memwrite,   // Write to the data memory
	output reg       dobranch,   // Perform a relative jump
	output reg       alusrcbimm, // Use the immediate value as second operand
	output reg [4:0] destreg,    // Number of the target register to (possibly) be written
	output reg [1:0] regwrite,   // Write to the target register
	output reg       dojump,     // Perform an absolute jump
	output reg [3:0] alucontrol  // ALU control bits
);
	// Extract the primary and secondary opcode
	wire [5:0] op = instr[31:26];
	wire [5:0] funct = instr[5:0];

	always @*
	begin
		case (op)
			6'b000000: // R-type instruction
				begin
					if (funct == 6'b001000) begin // jr
						regwrite = 0;
						destreg = 5'b11111;
						alusrcbimm = 0;
						dobranch = 0;
						memwrite = 0;
						memtoreg = 0;
						dojump = 1;
						alucontrol = 4'bxxxx; //default (undefined) behavior of ALU
					end
					else begin
						regwrite = 1;
						destreg = instr[15:11];
						alusrcbimm = 0;
						dobranch = 0;
						memwrite = 0;
						memtoreg = 0;
						dojump = 0;
						case (funct)
							6'b100001: alucontrol = 4'b0010; // addition unsigned
							6'b100011: alucontrol = 4'b0110; // subtraction unsigned
							6'b100100: alucontrol = 4'b0000; // and
							6'b100101: alucontrol = 4'b0001; // or
							6'b101011: alucontrol = 4'b1110; // set-less-than unsigned
							6'b010000: alucontrol = 4'b1100; // mfhi
							6'b010010: alucontrol = 4'b1010; // mflo
							6'b011001: alucontrol = 4'b0111; // mult
							default:   alucontrol = 4'b1111; // undefined
						endcase
					end
				end
			6'b100011, // Load data word from memory
			6'b101011: // Store data word
				begin
					regwrite = ~op[3];
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = op[3];
					memtoreg = 1;
					dojump = 0;
					alucontrol = 4'b0010;// TODO // Effective address: Base register + offset  example: 4($a0)
				end
			6'b000100: // Branch Equal
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 0;
					dobranch = zero; // Equality test
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 4'b0110; // Subtraction
				end
			6'b001001: // Addition immediate unsigned
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 4'b0010; // Addition
				end
			6'b000010: // Jump immediate
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					alucontrol = 4'b1111; //default (undefined) behavior of ALU
				end
			6'b001101: //ori 001101
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 4'b0001;
				end
			6'b001111: //lui 001111
				begin
					regwrite = 1;
					destreg = instr[20:16];
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 4'b1000;
				end
				//implement the bltz instruction with the opcode 000001
			6'b000001: //bltz 000001
				begin
					regwrite = 0;
					destreg = 5'bx;
					alusrcbimm = 1;
					dobranch = zero;
					memwrite = 0;
					memtoreg = 0;
					dojump = 0;
					alucontrol = 4'b1110; // Comparison
				end
			6'b000011: //jal 000011
				begin
					regwrite = 2'b10;
					destreg = 5'b11111;
					alusrcbimm = 1;
					dobranch = 0;
					memwrite = 0;
					memtoreg = 0;
					dojump = 1;
					alucontrol = 4'bx; // Default
				end
			default: // Default case
				begin
					regwrite = 2'bx;
					destreg = 5'bx;
					alusrcbimm = 1'bx;
					dobranch = 1'bx;
					memwrite = 1'bx;
					memtoreg = 1'bx;
					dojump = 1'bx;
					alucontrol = 4'bx; //default (undefined) behavior of ALU
				end
		endcase
	end
endmodule

