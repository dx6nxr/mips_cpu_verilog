module ALUtest();

wire [31:0] res;
wire zero;

// Instantiate the ALU module under test
ArithmeticLogicUnit alu(
    .a(32'h00000011),
    .b(32'h00000001),
    .alucontrol(3'b110),
    .result(res),
    .zero(zero)
);

	initial
	begin
		$dumpfile("divsim.vcd");
		$dumpvars;
		#5;
		if (zero == 0)
			$display("Simulation succeeded");
		else
			$display("Simulation failed");
	end

endmodule