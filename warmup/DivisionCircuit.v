module Division(
	input         clock,
	input         start,
	input  [N-1:0] a,
	input  [N-1:0] b,
	output [N-1:0] q,
	output [N-1:0] r
);

parameter N = 32;

reg [N-1:0] R, B, Q;
integer counter;

assign q = Q;
assign r = R;

  always @(posedge clock) begin
      if (start) begin
		counter = N;
		R <= 0;
		B <= b;
		Q <= a;
	  end
	  else if (counter >= 0) begin
		counter = counter - 1;
		R = {R[N-2:0], a[counter]};
			if (R < B) begin
				Q[counter] = 1'b0;
			end
			else begin
				Q[counter] = 1'b1;
				R = R - B;
			end
	  end
  end

endmodule