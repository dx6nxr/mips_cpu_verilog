module MealyPattern(
	input        clock,
	input        i,
	output [1:0] o
);

    parameter S0 = 4'h1;
    parameter S1 = 4'h2;
    parameter S2 = 4'h3;

  reg [2:0] state, next_state;
  reg [2:0] state1, next_state1;

  always @(posedge clock) begin
      state <= next_state;
      state1 <= next_state1;
  end

  always @(state1 or i) begin
    case(state1)
      S0: begin
           if(i == 0) next_state1 = S0;
           else       next_state1 = S1;
         end
      S1: begin
           if(i == 0) next_state1 = S2;
           else       next_state1 = S1;
         end
      S2: begin
           if(i == 0) next_state1 = S0;
           else       next_state1 = S1;
         end
      default: begin 
		next_state1 = S0;
		state1 = S0;
	  end
    endcase
  end
  assign o[0] = (state1 == S2) && i ? 1:0;

  always @(state or i) begin
    case(state)
      S0: begin
           if(i == 0) next_state = S1;
           else       next_state = S0;
         end
      S1: begin
           if(i == 0) next_state = S0;
           else       next_state = S2;
         end
      S2: begin
           if(i == 0) next_state = S1;
           else       next_state = S0;
         end
      default: begin 
		next_state = S0;
		state = S0;
	  end
    endcase
  end
  assign o[1] = (state == S2) && !i ? 1:0;

endmodule

module MealyPatternTestbench();
//inputs
reg i;
reg clock;
//output
wire [0:1]o;

MealyPattern machine(.clock(clock), .i(i), .o(o));

initial begin
    clock = 0;
    i = 0;
end

always
	#5 clock = !clock;

initial 
begin  
    //0110101011
    #10 i = 0;
    #10 i = 1; 
    #10 i = 1; 
    #10 i = 0;
    #10 i = 1;
    #10 i = 0;
    #10 i = 1;
    #10 i = 0;
    #10 i = 1;
    #10 i = 1;
    #10 $finish;
end

initial begin
$dumpfile("dump.vcd");
$dumpvars;
end

endmodule

