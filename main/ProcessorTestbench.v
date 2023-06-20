module ProcessorTestbench();

	reg clk;
	reg reset;

	integer i;
	reg [31:0] expectedRegContent [1:31];

	// Instantiate the Verilog module under test
	Processor proc(clk, reset);

	initial
		begin
			// Generate a waveform output with all (non-memory) variables
			$dumpfile("simres.vcd");
			$dumpvars(0, ProcessorTestbench);

			// initialize actual and expected registers to 0xcafebabe
			for(i=1; i<32; i=i+1) begin
				proc.mips.dp.gpr.registers[i] = 32'b0;
				expectedRegContent[i] = 32'b0;
			end

			// Read program to be executed
//			$readmemh("main/TestPrograms/Fibonacci.dat", proc.imem.INSTRROM, 0, 5);
//			$readmemh("main/TestPrograms/Fibonacci.expected", expectedRegContent);
//			$readmemh("main/TestPrograms/FunctionCall.dat", proc.imem.INSTRROM, 0, 4);
//			$readmemh("main/TestPrograms/FunctionCall.expected", expectedRegContent);
//			$readmemh("main/TestPrograms/Constants.dat", proc.imem.INSTRROM, 0, 1);
//			$readmemh("main/TestPrograms/Constants.expected", expectedRegContent);
//			$readmemh("main/TestPrograms/Multiplication.dat", proc.imem.INSTRROM, 0, 4);
//			$readmemh("main/TestPrograms/Multiplication.expected", expectedRegContent);
//			$readmemh("main/TestPrograms/BranchTest.dat", proc.imem.INSTRROM, 0, 6);
//			$readmemh("main/TestPrograms/BranchTest.expected", expectedRegContent);
//			$readmemh("main/TestPrograms/Mult.dat", proc.imem.INSTRROM, 0, 4);
//			$readmemh("main/TestPrograms/Mult.expected", expectedRegContent);
			$readmemh("main/TestPrograms/testAll.dat", proc.imem.INSTRROM, 0, 12);
			$readmemh("main/TestPrograms/testAll.expected", expectedRegContent);

			// Generate reset input
			reset <= 1;
			#5; reset <= 0;
			// Number of simulated cycles
//			#117; // Fibonacci
//			#20; // FunctionCall
//			#16; // Constants
//			#24; // Multiplication
			#400;

			for(i=1; i<32; i=i+1) begin
				$display("Register %d = %h", i, proc.mips.dp.gpr.registers[i]);
			end
			for(i=1; i<32; i=i+1) begin
				if(^proc.mips.dp.gpr.registers[i] === 1'bx || proc.mips.dp.gpr.registers[i] != expectedRegContent[i]) begin
					$write("FAILED");
					$display(": register %d = %h, expected %h",i, proc.mips.dp.gpr.registers[i], expectedRegContent[i]);
					$finish;
				end
			end
			$display("PASSED");
			$finish;
		end

	// Generate a periodic clock signal
	always
		begin
			clk <= 1; #2; clk <= 0; #2;
		end

endmodule

