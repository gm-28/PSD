module rc_adder(
		 input signed [31:0] inA, 
		 input signed [31:0] inB,
		 input Cin, 

		 output signed [31:0] add,
		 output Co
 	); 
	wire [31:0] c;

	genvar i;
	assign c[0] =Cin;
	generate
		for(i = 0; i <= 30; i = i + 1) 
			begin    
				fulladder u(
					.inA(inA[i]), 
					.inB(inB[i]),
					.Cin(c[i]),
					.add(add[i]), 
					.Co(c[i+1])
				); 
			end 
	endgenerate
	fulladder u32(inA[31], inB[31], c[31], add[31], Co);
 endmodule