module ALUtest();

wire [31:0] res;
wire zero;

// Instantiate the ALU module under test
ArithmeticLogicUnit alu(
    .a(32'b00000000000010010000000000000000),
	//32 bit a value
    .b(32'b00000000000000000000000010001001),
	//32 bit b valur, extended to 32 bits
    .alucontrol(3'b011),
    .result(res),
    .zero(zero)
);

	initial
	begin
		$dumpfile("divsim.vcd");
		$dumpvars;
		#5;
		if (res == 32'b00000000000010010000000010001001)
			$display("Simulation succeeded");
		else
			$display("Simulation failed");
	end

endmodule